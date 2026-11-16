<?php

declare(strict_types=1);

require_once dirname(__DIR__, 2) . '/app_private/config/database.php';
require_once dirname(__DIR__, 2) . '/app_private/services/EjercicioService.php';

require_post();

try {
    $body = read_json_body();
    $intentoId = (int) ($body['attemptId'] ?? $body['intento_id'] ?? 0);
    $ejercicioId = (int) ($body['exerciseId'] ?? $body['ejercicio_id'] ?? 0);
    $respuesta = (string) ($body['answer'] ?? $body['respuesta'] ?? '');
    $respuestaNumero = array_key_exists('numericValue', $body) && $body['numericValue'] !== null ? (float) $body['numericValue'] : null;
    $correcta = (int) (bool) ($body['correct'] ?? $body['correcta'] ?? false);
    $duracionActiva = array_key_exists('elapsedSeconds', $body) || array_key_exists('duracion_segundos', $body)
        ? max(0, (int) ($body['elapsedSeconds'] ?? $body['duracion_segundos'] ?? 0))
        : null;

    if ($intentoId <= 0 || $ejercicioId <= 0) {
        json_response(['ok' => false, 'message' => 'Faltan datos para guardar el progreso.'], 422);
    }

    $combinacion = (new EjercicioService())->obtenerCombinacionAsignada($ejercicioId, $intentoId);
    $combinacionId = $combinacion ? (int) $combinacion['id'] : null;

    $stmt = db()->prepare(
        'INSERT INTO respuestas (intento_id, ejercicio_id, combinacion_ejercicio_id, respuesta_texto, respuesta_numero, correcta)
         VALUES (?, ?, ?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE combinacion_ejercicio_id = VALUES(combinacion_ejercicio_id), respuesta_texto = VALUES(respuesta_texto), respuesta_numero = VALUES(respuesta_numero), correcta = VALUES(correcta), respondido_en = NOW()'
    );
    $stmt->execute([$intentoId, $ejercicioId, $combinacionId, $respuesta, $respuestaNumero, $correcta]);

    $duracionSql = $duracionActiva !== null ? '?' : 'TIMESTAMPDIFF(SECOND, iniciado_en, NOW())';
    $params = [$ejercicioId, $intentoId, $intentoId];
    if ($duracionActiva !== null) {
        $params[] = $duracionActiva;
    }
    $params[] = $intentoId;

    $stmt = db()->prepare(
        "UPDATE intentos
         SET ultimo_ejercicio_id = ?,
             ultimo_acceso_en = NOW(),
             estado = 'en_progreso',
             cantidad_respuestas = (
               SELECT COUNT(*) FROM respuestas WHERE intento_id = ?
             ),
             correctas = (
               SELECT COUNT(*) FROM respuestas WHERE intento_id = ? AND correcta = 1
             ),
             duracion_segundos = {$duracionSql}
         WHERE id = ?"
    );
    $stmt->execute($params);

    json_response(['ok' => true, 'data' => ['saved' => true]]);
} catch (Throwable $exception) {
    json_response(['ok' => false, 'message' => 'No se pudo guardar el progreso.'], 500);
}
