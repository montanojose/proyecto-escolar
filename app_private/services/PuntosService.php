<?php

declare(strict_types=1);

require_once dirname(__DIR__) . '/config/database.php';

final class PuntosService
{
    public function finalizarActividad(array $payload): array
    {
        $actividadId = (int) ($payload['activityId'] ?? $payload['actividad_id'] ?? 0);
        $alumnoId = (int) ($payload['studentId'] ?? $payload['alumno_id'] ?? 0);
        $intentoId = (int) ($payload['attemptId'] ?? $payload['intento_id'] ?? 0);
        $correctas = (int) ($payload['correct'] ?? $payload['correctas'] ?? 0);
        $intentos = (int) ($payload['attempts'] ?? $payload['intentos'] ?? 0);
        $puntaje = (int) ($payload['score'] ?? $payload['puntaje'] ?? 0);
        $duracionActiva = array_key_exists('elapsedSeconds', $payload) || array_key_exists('duracion_segundos', $payload)
            ? max(0, (int) ($payload['elapsedSeconds'] ?? $payload['duracion_segundos'] ?? 0))
            : null;

        if ($actividadId <= 0 || $alumnoId <= 0) {
            throw new InvalidArgumentException('Faltan datos para finalizar la actividad.');
        }

        $pdo = db();
        $pdo->beginTransaction();

        try {
            $contexto = $this->obtenerContextoActividad($actividadId, $intentoId);
            $actividad = $contexto['actividad'];
            $actividadClaseId = $contexto['actividad_clase_id'];
            $puntajeHabilitado = (bool) ($actividad['puntaje_habilitado'] ?? false);
            $yaSumoPuntos = $this->yaSumoPuntos($alumnoId, $actividadId, $intentoId, $actividadClaseId);
            $puntajeFinal = $puntajeHabilitado && !$yaSumoPuntos ? $puntaje : 0;
            $modo = $puntajeHabilitado ? 'evaluativo' : 'practica';

            if ($intentoId > 0) {
                $duracionSql = $duracionActiva !== null ? '?' : 'TIMESTAMPDIFF(SECOND, iniciado_en, NOW())';
                $params = [$correctas, $intentos, $puntajeFinal, $modo];
                if ($duracionActiva !== null) {
                    $params[] = $duracionActiva;
                }
                $params = [...$params, $intentoId, $alumnoId, $actividadId];

                $stmt = $pdo->prepare(
                    "UPDATE intentos
                     SET correctas = ?, cantidad_respuestas = ?, puntaje = ?, modo = ?, estado = 'finalizado',
                         ultimo_acceso_en = NOW(), finalizado_en = NOW(),
                         duracion_segundos = {$duracionSql}
                     WHERE id = ? AND alumno_id = ? AND actividad_id = ?"
                );
                $stmt->execute($params);
            } else {
                $stmt = $pdo->prepare(
                     "INSERT INTO intentos
                     (alumno_id, actividad_id, modo, estado, correctas, cantidad_respuestas, puntaje, finalizado_en, duracion_segundos)
                     VALUES (?, ?, ?, 'finalizado', ?, ?, ?, NOW(), ?)"
                );
                $stmt->execute([$alumnoId, $actividadId, $modo, $correctas, $intentos, $puntajeFinal, $duracionActiva ?? 0]);
                $intentoId = (int) $pdo->lastInsertId();
            }

            if ($puntajeFinal > 0) {
                $stmt = $pdo->prepare(
                    'INSERT INTO movimientos_puntos (alumno_id, actividad_id, actividad_clase_id, intento_id, puntos, motivo)
                     VALUES (?, ?, ?, ?, ?, ?)'
                );
                $stmt->execute([$alumnoId, $actividadId, $actividadClaseId ?: null, $intentoId, $puntajeFinal, 'Actividad finalizada']);
            }

            $pdo->commit();

            return [
                'saved' => true,
                'attemptId' => $intentoId,
                'mode' => $modo,
                'pointsEnabled' => $puntajeHabilitado,
                'points' => $puntajeFinal,
                'alreadyAwarded' => $yaSumoPuntos,
            ];
        } catch (Throwable $exception) {
            $pdo->rollBack();
            throw $exception;
        }
    }

    public function resumenAdmin(): array
    {
        $pdo = db();

        $activeActivities = (int) $pdo->query("SELECT COUNT(*) FROM actividades WHERE estado = 'Disponible'")->fetchColumn();
        $participants = (int) $pdo->query('SELECT COUNT(DISTINCT alumno_id) FROM intentos')->fetchColumn();
        $awardedPoints = (int) $pdo->query('SELECT COALESCE(SUM(puntos), 0) FROM movimientos_puntos')->fetchColumn();

        $rows = $pdo->query(
            "SELECT a.titulo,
                    IF(a.estado = 'Disponible', 'Activa', a.estado) AS estado,
                    COUNT(DISTINCT i.alumno_id) AS participantes,
                    COALESCE(ROUND(AVG(i.correctas / NULLIF(i.cantidad_respuestas, 0)) * 100), 0) AS aciertos
             FROM actividades a
             LEFT JOIN intentos i ON i.actividad_id = a.id
             GROUP BY a.id
             ORDER BY a.orden, a.id
             LIMIT 10"
        )->fetchAll();

        return [
            'activeActivities' => $activeActivities,
            'participants' => $participants,
            'awardedPoints' => $awardedPoints,
            'rows' => array_map(
                fn (array $row): array => [
                    (string) $row['titulo'],
                    (string) $row['estado'],
                    (string) $row['participantes'],
                    ((int) $row['aciertos']) . '%',
                ],
                $rows
            ),
        ];
    }

    private function obtenerContextoActividad(int $actividadId, int $intentoId): array
    {
        $actividadClaseId = 0;
        if ($intentoId > 0) {
            $stmt = db()->prepare('SELECT actividad_clase_id FROM intentos WHERE id = ? LIMIT 1');
            $stmt->execute([$intentoId]);
            $actividadClaseId = (int) ($stmt->fetchColumn() ?: 0);
        }

        if ($actividadClaseId > 0) {
            $stmt = db()->prepare(
                'SELECT ac.id, ac.acceso_habilitado, ac.puntaje_habilitado
                 FROM actividades_clase ac
                 WHERE ac.id = ? AND ac.actividad_id = ?
                 LIMIT 1'
            );
            $stmt->execute([$actividadClaseId, $actividadId]);
            $actividad = $stmt->fetch();

            if (!$actividad) {
                throw new InvalidArgumentException('La actividad asignada no existe.');
            }

            if ((int) $actividad['acceso_habilitado'] !== 1) {
                throw new InvalidArgumentException('La actividad todavÃ­a no estÃ¡ habilitada para ingresar.');
            }

            return ['actividad' => $actividad, 'actividad_clase_id' => $actividadClaseId];
        }

        return ['actividad' => $this->obtenerActividad($actividadId), 'actividad_clase_id' => 0];
    }

    private function obtenerActividad(int $actividadId): array
    {
        $stmt = db()->prepare('SELECT id, acceso_habilitado, puntaje_habilitado FROM actividades WHERE id = ? LIMIT 1');
        $stmt->execute([$actividadId]);
        $actividad = $stmt->fetch();

        if (!$actividad) {
            throw new InvalidArgumentException('La actividad no existe.');
        }

        if ((int) $actividad['acceso_habilitado'] !== 1) {
            throw new InvalidArgumentException('La actividad todavía no está habilitada para ingresar.');
        }

        return $actividad;
    }

    private function yaSumoPuntos(int $alumnoId, int $actividadId, int $intentoId, int $actividadClaseId = 0): bool
    {
        $scopeSql = $actividadClaseId > 0 ? 'AND actividad_clase_id = ?' : 'AND actividad_clase_id IS NULL';
        $params = [$alumnoId, $actividadId];
        if ($actividadClaseId > 0) {
            $params[] = $actividadClaseId;
        }
        $params[] = $intentoId;
        $params[] = $intentoId;

        $stmt = db()->prepare(
            "SELECT COUNT(*)
             FROM movimientos_puntos
             WHERE alumno_id = ?
               AND actividad_id = ?
               {$scopeSql}
               AND puntos > 0
               AND (? = 0 OR intento_id <> ?)"
        );
        $stmt->execute($params);

        return (int) $stmt->fetchColumn() > 0;
    }
}
