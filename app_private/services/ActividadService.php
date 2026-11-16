<?php

declare(strict_types=1);

require_once dirname(__DIR__) . '/config/database.php';

final class ActividadService
{
    public function listar(?int $alumnoId = null): array
    {
        if ($alumnoId && $this->tieneActividadesAsignadas($alumnoId)) {
            return $this->listarParaAlumno($alumnoId);
        }

        $sql = <<<'SQL'
            SELECT a.id, a.titulo, a.descripcion, a.nivel, a.puntos, a.estado,
                   a.visible_alumno, a.acceso_habilitado, a.puntaje_habilitado, a.icono,
                   t.nombre AS tema,
                   CASE
                     WHEN t.nombre = 'Lengua' AND a.titulo = 'Reconocemos el sujeto y el predicado'
                     THEN 'lengua_sujeto_predicado'
                     WHEN t.nombre = 'Matemática' AND a.titulo = 'Aplicaciones de la función racional: calcular, observar e interpretar'
                     THEN 'matematica_funcion_racional'
                     ELSE 'ejercicios'
                   END AS tipo_actividad,
                   COUNT(e.id) AS ejercicios,
                   (SELECT COUNT(*) FROM lengua_oraciones WHERE activa = 1) AS combinaciones_lengua
            FROM actividades a
            INNER JOIN contenedores_actividad ca ON ca.id = a.contenedor_id
            INNER JOIN temas t ON t.id = ca.tema_id
            LEFT JOIN ejercicios e ON e.actividad_id = a.id AND e.activo = 1
            WHERE a.visible_alumno = 1
            GROUP BY a.id
            ORDER BY a.orden, a.id
        SQL;

        return array_map([$this, 'mapear'], db()->query($sql)->fetchAll());
    }

    private function listarParaAlumno(int $alumnoId): array
    {
        $sql = <<<'SQL'
            SELECT a.id, a.titulo, a.descripcion, a.nivel, a.puntos,
                   ac.estado, ac.visible_alumno, ac.acceso_habilitado, ac.puntaje_habilitado, a.icono,
                   ac.id AS actividad_clase_id, cd.id AS clase_id, cd.nombre AS clase, cd.codigo AS codigo_clase,
                   t.nombre AS tema,
                   CASE
                     WHEN t.nombre = 'Lengua' AND a.titulo = 'Reconocemos el sujeto y el predicado'
                     THEN 'lengua_sujeto_predicado'
                     WHEN t.nombre = 'MatemÃ¡tica' AND a.titulo = 'Aplicaciones de la funciÃ³n racional: calcular, observar e interpretar'
                     THEN 'matematica_funcion_racional'
                     ELSE 'ejercicios'
                   END AS tipo_actividad,
                   COUNT(e.id) AS ejercicios,
                   (SELECT COUNT(*) FROM lengua_oraciones WHERE activa = 1) AS combinaciones_lengua
            FROM inscripciones_clase ic
            INNER JOIN clases_docente cd ON cd.id = ic.clase_id AND cd.activa = 1
            INNER JOIN actividades_clase ac ON ac.clase_id = cd.id
            INNER JOIN actividades a ON a.id = ac.actividad_id
            INNER JOIN contenedores_actividad ca ON ca.id = a.contenedor_id
            INNER JOIN temas t ON t.id = ca.tema_id
            LEFT JOIN ejercicios e ON e.actividad_id = a.id AND e.activo = 1
            WHERE ic.alumno_id = ?
              AND ic.estado = 'validada'
              AND ac.visible_alumno = 1
              AND (ac.fecha_inicio IS NULL OR ac.fecha_inicio <= NOW())
              AND (ac.fecha_cierre IS NULL OR ac.fecha_cierre >= NOW())
            GROUP BY ac.id, a.id, cd.id
            ORDER BY cd.nombre, ac.orden, a.orden, a.id
        SQL;

        $stmt = db()->prepare($sql);
        $stmt->execute([$alumnoId]);

        return array_map([$this, 'mapear'], $stmt->fetchAll());
    }

    private function tieneActividadesAsignadas(int $alumnoId): bool
    {
        $stmt = db()->prepare(
            "SELECT COUNT(*)
             FROM inscripciones_clase ic
             INNER JOIN actividades_clase ac ON ac.clase_id = ic.clase_id
             WHERE ic.alumno_id = ? AND ic.estado = 'validada'"
        );
        $stmt->execute([$alumnoId]);

        return (int) $stmt->fetchColumn() > 0;
    }

    public function obtener(int $id): ?array
    {
        $stmt = db()->prepare(
            <<<'SQL'
            SELECT a.id, a.titulo, a.descripcion, a.nivel, a.puntos, a.estado, a.visible_alumno,
                    a.acceso_habilitado, a.puntaje_habilitado, a.icono, t.nombre AS tema,
                    CASE
                      WHEN t.nombre = 'Lengua' AND a.titulo = 'Reconocemos el sujeto y el predicado'
                      THEN 'lengua_sujeto_predicado'
                      WHEN t.nombre = 'Matemática' AND a.titulo = 'Aplicaciones de la función racional: calcular, observar e interpretar'
                      THEN 'matematica_funcion_racional'
                      ELSE 'ejercicios'
                    END AS tipo_actividad,
                    0 AS ejercicios,
                    (SELECT COUNT(*) FROM lengua_oraciones WHERE activa = 1) AS combinaciones_lengua
             FROM actividades a
             INNER JOIN contenedores_actividad ca ON ca.id = a.contenedor_id
             INNER JOIN temas t ON t.id = ca.tema_id
             WHERE a.id = ? LIMIT 1
            SQL
        );
        $stmt->execute([$id]);
        $actividad = $stmt->fetch();

        return $actividad ? $this->mapear($actividad) : null;
    }

    private function mapear(array $actividad): array
    {
        return [
            'id' => (int) $actividad['id'],
            'title' => (string) $actividad['titulo'],
            'desc' => (string) $actividad['descripcion'],
            'level' => (string) $actividad['nivel'],
            'points' => (int) $actividad['puntos'],
            'exercises' => match ((string) ($actividad['tipo_actividad'] ?? '')) {
                'lengua_sujeto_predicado' => 4,
                'matematica_funcion_racional' => 22,
                default => (int) $actividad['ejercicios'],
            },
            'combinations' => match ((string) ($actividad['tipo_actividad'] ?? '')) {
                'lengua_sujeto_predicado' => (int) ($actividad['combinaciones_lengua'] ?? 0),
                'matematica_funcion_racional' => 64,
                default => 0,
            },
            'state' => (string) $actividad['estado'],
            'visible' => (bool) $actividad['visible_alumno'],
            'accessEnabled' => (bool) $actividad['acceso_habilitado'],
            'pointsEnabled' => (bool) $actividad['puntaje_habilitado'],
            'icon' => (string) $actividad['icono'],
            'topic' => (string) ($actividad['tema'] ?? ''),
            'activityType' => (string) ($actividad['tipo_actividad'] ?? 'ejercicios'),
            'classActivityId' => isset($actividad['actividad_clase_id']) ? (int) $actividad['actividad_clase_id'] : null,
            'classId' => isset($actividad['clase_id']) ? (int) $actividad['clase_id'] : null,
            'className' => isset($actividad['clase']) ? (string) $actividad['clase'] : null,
            'classCode' => isset($actividad['codigo_clase']) ? (string) $actividad['codigo_clase'] : null,
        ];
    }
}
