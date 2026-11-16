<?php

declare(strict_types=1);

require_once dirname(__DIR__, 3) . '/app_private/config/session.php';

try {
    require_post();

    $docente = (new DocenteService())->registrar(read_json_body());
    iniciar_sesion_docente((string) $docente['dni']);

    json_response([
        'ok' => true,
        'data' => [
            'authorized' => true,
            'teacher' => docente_actual(),
        ],
    ], 201);
} catch (InvalidArgumentException $exception) {
    json_response(['ok' => false, 'message' => $exception->getMessage()], 422);
} catch (Throwable $exception) {
    json_response(['ok' => false, 'message' => 'No se pudo registrar el docente.'], 500);
}
