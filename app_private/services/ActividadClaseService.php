<?php

declare(strict_types=1);

require_once dirname(__DIR__) . '/config/database.php';

final class ActividadClaseService
{
    public function listarCatalogo(int $docenteId, ?int $claseId = null): array
    {
        $params = [];
        $join = '';
        if ($claseId) {
            $join = 'LEFT JOIN actividades_clase ac ON ac.actividad_id = a.id AND ac.clase_id = ?';
            $params[] = $claseId;
        } else {
            $join = 'LEFT JOIN actividades_clase ac ON 1 = 0';
        }

        $sql = "SELECT a.id, a.titulo, a.descripcion, a.nivel, a.puntos, a.estado,
                       a.visible_alumno, a.acceso_habilitado, a.puntaje_habilitado, a.icono,
                       t.nombre AS tema, tp.titulo AS trabajo_practico, st.titulo AS seccion,
                       COUNT(e.id) AS ejercicios,
                       ac.id AS actividad_clase_id,
                       ac.visible_alumno AS clase_visible,
                       ac.acceso_habilitado AS clase_acceso,
                       ac.puntaje_habilitado AS clase_puntos,
                       ac.estado AS clase_estado,
                       ac.orden AS clase_orden
                FROM actividades a
                INNER JOIN contenedores_actividad ca ON ca.id = a.contenedor_id
                INNER JOIN temas t ON t.id = ca.tema_id
                LEFT JOIN secciones_tp st ON st.id = a.seccion_tp_id
                LEFT JOIN trabajos_practicos tp ON tp.id = st.trabajo_practico_id
                LEFT JOIN ejercicios e ON e.actividad_id = a.id AND e.activo = 1
                {$join}
                GROUP BY a.id, ac.id
                ORDER BY t.nombre, a.orden, a.id";

        $stmt = db()->prepare($sql);
        $stmt->execute($params);

        return array_map(fn (array $row): array => [
            'id' => (int) $row['id'],
            'activityId' => (int) $row['id'],
            'classActivityId' => $row['actividad_clase_id'] ? (int) $row['actividad_clase_id'] : null,
            'assigned' => $row['actividad_clase_id'] !== null,
            'title' => (string) $row['titulo'],
            'desc' => (string) $row['descripcion'],
            'topic' => (string) $row['tema'],
            'work' => $row['trabajo_practico'] ? (string) $row['trabajo_practico'] : null,
            'section' => $row['seccion'] ? (string) $row['seccion'] : null,
            'level' => (string) $row['nivel'],
            'points' => (int) $row['puntos'],
            'exercises' => (int) $row['ejercicios'],
            'state' => (string) ($row['clase_estado'] ?? $row['estado']),
            'visible' => (bool) ($row['clase_visible'] ?? $row['visible_alumno']),
            'accessEnabled' => (bool) ($row['clase_acceso'] ?? $row['acceso_habilitado']),
            'pointsEnabled' => (bool) ($row['clase_puntos'] ?? $row['puntaje_habilitado']),
            'icon' => (string) $row['icono'],
        ], $stmt->fetchAll());
    }

    public function asignar(int $docenteId, int $claseId, int $actividadId, array $data = []): array
    {
        $this->asegurarClaseDocente($docenteId, $claseId);

        $stmt = db()->prepare(
            'INSERT INTO actividades_clase
                 (clase_id, actividad_id, visible_alumno, acceso_habilitado, puntaje_habilitado, estado, orden)
             VALUES (?, ?, ?, ?, ?, ?, ?)
             ON DUPLICATE KEY UPDATE
                 visible_alumno = VALUES(visible_alumno),
                 acceso_habilitado = VALUES(acceso_habilitado),
                 puntaje_habilitado = VALUES(puntaje_habilitado),
                 estado = VALUES(estado),
                 orden = VALUES(orden)'
        );
        $stmt->execute([
            $claseId,
            $actividadId,
            input_bool($data, 'visible_alumno', true) ? 1 : 0,
            input_bool($data, 'acceso_habilitado', true) ? 1 : 0,
            input_bool($data, 'puntaje_habilitado', false) ? 1 : 0,
            input_string($data, 'estado', 'Practica'),
            input_int($data, 'orden', 100),
        ]);

        return $this->obtenerAsignacion($docenteId, $claseId, $actividadId);
    }

    public function cambiarEstado(int $docenteId, int $actividadClaseId, array $data): array
    {
        $stmt = db()->prepare(
            'UPDATE actividades_clase ac
             INNER JOIN clases_docente cd ON cd.id = ac.clase_id
             SET ac.visible_alumno = ?, ac.acceso_habilitado = ?, ac.puntaje_habilitado = ?, ac.estado = ?
             WHERE ac.id = ? AND cd.docente_id = ?'
        );
        $stmt->execute([
            input_bool($data, 'visible_alumno', true) ? 1 : 0,
            input_bool($data, 'acceso_habilitado', false) ? 1 : 0,
            input_bool($data, 'puntaje_habilitado', false) ? 1 : 0,
            input_string($data, 'estado', 'Practica'),
            $actividadClaseId,
            $docenteId,
        ]);

        return $this->obtenerAsignacionPorId($docenteId, $actividadClaseId);
    }

    public function desasignar(int $docenteId, int $actividadClaseId): array
    {
        $asignacion = $this->obtenerAsignacionPorId($docenteId, $actividadClaseId);
        $stmt = db()->prepare(
            'DELETE ac
             FROM actividades_clase ac
             INNER JOIN clases_docente cd ON cd.id = ac.clase_id
             WHERE ac.id = ? AND cd.docente_id = ?'
        );
        $stmt->execute([$actividadClaseId, $docenteId]);

        return $asignacion;
    }

    private function obtenerAsignacion(int $docenteId, int $claseId, int $actividadId): array
    {
        $stmt = db()->prepare(
            'SELECT ac.*
             FROM actividades_clase ac
             INNER JOIN clases_docente cd ON cd.id = ac.clase_id
             WHERE ac.clase_id = ? AND ac.actividad_id = ? AND cd.docente_id = ?
             LIMIT 1'
        );
        $stmt->execute([$claseId, $actividadId, $docenteId]);
        $row = $stmt->fetch();

        if (!$row) {
            throw new InvalidArgumentException('No encontramos esa asignación.');
        }

        return $row;
    }

    private function obtenerAsignacionPorId(int $docenteId, int $actividadClaseId): array
    {
        $stmt = db()->prepare(
            'SELECT ac.*
             FROM actividades_clase ac
             INNER JOIN clases_docente cd ON cd.id = ac.clase_id
             WHERE ac.id = ? AND cd.docente_id = ?
             LIMIT 1'
        );
        $stmt->execute([$actividadClaseId, $docenteId]);
        $row = $stmt->fetch();

        if (!$row) {
            throw new InvalidArgumentException('No encontramos esa asignación.');
        }

        return $row;
    }

    private function asegurarClaseDocente(int $docenteId, int $claseId): void
    {
        $stmt = db()->prepare('SELECT COUNT(*) FROM clases_docente WHERE id = ? AND docente_id = ?');
        $stmt->execute([$claseId, $docenteId]);
        if ((int) $stmt->fetchColumn() !== 1) {
            throw new InvalidArgumentException('Esa clase no pertenece al docente logueado.');
        }
    }
}
