<?php

declare(strict_types=1);

require_once dirname(__DIR__, 3) . '/app_private/services/ContenidoService.php';
require_once dirname(__DIR__, 3) . '/app_private/config/session.php';

require_docente();

try {
    if (request_method() !== 'GET') {
        json_response(['ok' => false, 'message' => 'Método no permitido.'], 405);
    }

    $service = new ContenidoService();
    $intentoId = (int) ($_GET['intento_id'] ?? 0);

    if ($intentoId > 0) {
        json_response([
            'ok' => true,
            'data' => $service->detalleIntento($intentoId),
        ]);
    }

    json_response([
        'ok' => true,
        'data' => $service->listarProgreso(
            (int) ($_GET['curso_id'] ?? 0) ?: null,
            (int) ($_GET['actividad_id'] ?? 0) ?: null,
            isset($_GET['estado']) && $_GET['estado'] !== '' ? (string) $_GET['estado'] : null,
            filter_var($_GET['pendientes'] ?? false, FILTER_VALIDATE_BOOLEAN)
        ),
    ]);
} catch (Throwable $exception) {
    json_response(['ok' => false, 'message' => 'No se pudo obtener el progreso.'], 500);
}
