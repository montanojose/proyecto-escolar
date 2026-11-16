<?php

declare(strict_types=1);

require_once dirname(__DIR__, 3) . '/app_private/config/session.php';

try {
    require_post();

    $body = read_json_body();
    $dni = normalize_dni((string) ($body['dni'] ?? ''));

    if (!iniciar_sesion_docente($dni)) {
        json_response(['ok' => false, 'message' => 'DNI docente no autorizado.'], 401);
    }

    json_response([
        'ok' => true,
        'data' => [
            'authorized' => true,
            'teacher' => docente_actual(),
        ],
    ]);
} catch (Throwable $exception) {
    json_response(['ok' => false, 'message' => 'No se pudo iniciar la sesion docente.'], 500);
}
