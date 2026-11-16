<?php

declare(strict_types=1);

require_once dirname(__DIR__, 2) . '/app_private/services/AlumnoService.php';

require_post();

try {
    $body = read_json_body();
    $student = (new AlumnoService())->buscarOCrearPorDni((string) ($body['dni'] ?? ''));

    json_response([
        'ok' => true,
        'data' => ['student' => $student],
    ]);
} catch (InvalidArgumentException $exception) {
    json_response(['ok' => false, 'message' => $exception->getMessage()], 422);
} catch (Throwable $exception) {
    json_response(['ok' => false, 'message' => 'No se pudo validar el DNI.'], 500);
}
