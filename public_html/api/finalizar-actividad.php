<?php

declare(strict_types=1);

require_once dirname(__DIR__, 2) . '/app_private/services/PuntosService.php';

require_post();

try {
    json_response([
        'ok' => true,
        'data' => (new PuntosService())->finalizarActividad(read_json_body()),
    ]);
} catch (InvalidArgumentException $exception) {
    json_response(['ok' => false, 'message' => $exception->getMessage()], 422);
} catch (Throwable $exception) {
    json_response(['ok' => false, 'message' => 'No se pudo finalizar la actividad.'], 500);
}
