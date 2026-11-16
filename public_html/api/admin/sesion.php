<?php

declare(strict_types=1);

require_once dirname(__DIR__, 3) . '/app_private/config/session.php';

try {
    if (request_method() !== 'GET') {
        json_response(['ok' => false, 'message' => 'Metodo no permitido.'], 405);
    }

    json_response([
        'ok' => true,
        'data' => [
            'authorized' => docente_autenticado(),
            'teacher' => docente_actual(),
        ],
    ]);
} catch (Throwable $exception) {
    json_response(['ok' => false, 'message' => 'No se pudo consultar la sesion docente.'], 500);
}
