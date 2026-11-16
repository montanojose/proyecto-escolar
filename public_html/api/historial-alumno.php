<?php

declare(strict_types=1);

require_once dirname(__DIR__, 2) . '/app_private/config/database.php';

try {
    $alumnoId = (int) ($_GET['student_id'] ?? $_GET['alumno_id'] ?? 0);

    if ($alumnoId <= 0) {
        json_response(['ok' => false, 'message' => 'Falta el alumno.'], 422);
    }

    $stmt = db()->prepare(
        "SELECT i.id AS intento_id, i.modo, i.estado, i.correctas, i.cantidad_respuestas,
                i.puntaje, i.iniciado_en, i.ultimo_acceso_en, i.finalizado_en,
                i.duracion_segundos,
                a.id AS actividad_id, a.titulo AS actividad,
                e.id AS ultimo_ejercicio_id, e.consigna AS ultimo_ejercicio
         FROM intentos i
         INNER JOIN actividades a ON a.id = i.actividad_id
         LEFT JOIN ejercicios e ON e.id = i.ultimo_ejercicio_id
         WHERE i.alumno_id = ?
         ORDER BY i.ultimo_acceso_en DESC, i.id DESC
         LIMIT 50"
    );
    $stmt->execute([$alumnoId]);

    json_response([
        'ok' => true,
        'data' => array_map(
            fn (array $row): array => [
                'attemptId' => (int) $row['intento_id'],
                'activityId' => (int) $row['actividad_id'],
                'activity' => (string) $row['actividad'],
                'mode' => (string) $row['modo'],
                'state' => (string) $row['estado'],
                'correct' => (int) $row['correctas'],
                'answers' => (int) $row['cantidad_respuestas'],
                'points' => (int) $row['puntaje'],
                'startedAt' => (string) $row['iniciado_en'],
                'lastAccessAt' => (string) $row['ultimo_acceso_en'],
                'finishedAt' => $row['finalizado_en'] ? (string) $row['finalizado_en'] : null,
                'durationSeconds' => (int) $row['duracion_segundos'],
                'lastExerciseId' => $row['ultimo_ejercicio_id'] ? (int) $row['ultimo_ejercicio_id'] : null,
                'lastExercise' => $row['ultimo_ejercicio'] ? (string) $row['ultimo_ejercicio'] : null,
            ],
            $stmt->fetchAll()
        ),
    ]);
} catch (Throwable $exception) {
    json_response(['ok' => false, 'message' => 'No se pudo obtener el historial del alumno.'], 500);
}
