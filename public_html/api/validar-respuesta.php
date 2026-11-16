<?php

declare(strict_types=1);

require_once dirname(__DIR__, 2) . '/app_private/services/EjercicioService.php';

require_post();

try {
    $body = read_json_body();
    $ejercicioId = (int) ($body['exerciseId'] ?? $body['ejercicio_id'] ?? 0);
    $respuesta = (string) ($body['answer'] ?? $body['respuesta'] ?? '');
    $intentoId = (int) ($body['attemptId'] ?? $body['intento_id'] ?? 0);

    json_response([
        'ok' => true,
        'data' => (new EjercicioService())->validar($ejercicioId, $respuesta, $intentoId > 0 ? $intentoId : null),
    ]);
} catch (InvalidArgumentException $exception) {
    json_response(['ok' => false, 'message' => $exception->getMessage()], 422);
} catch (Throwable $exception) {
    json_response(['ok' => false, 'message' => 'No se pudo validar la respuesta.'], 500);
}
