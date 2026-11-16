<?php

declare(strict_types=1);

require_once dirname(__DIR__, 3) . '/app_private/services/ContenidoService.php';
require_once dirname(__DIR__, 3) . '/app_private/config/session.php';

require_docente();

try {
    if (request_method() !== 'GET') {
        json_response(['ok' => false, 'message' => 'Metodo no permitido.'], 405);
    }

    json_response([
        'ok' => true,
        'data' => (new ContenidoService())->listarEjerciciosAdmin(
            (int) ($_GET['actividad_id'] ?? 0) ?: null
        ),
    ]);
} catch (Throwable $exception) {
    json_response(['ok' => false, 'message' => 'No se pudieron obtener los ejercicios.'], 500);
}
