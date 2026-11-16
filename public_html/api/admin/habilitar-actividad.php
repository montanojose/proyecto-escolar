<?php

declare(strict_types=1);

require_once dirname(__DIR__, 3) . '/app_private/services/ContenidoService.php';
require_once dirname(__DIR__, 3) . '/app_private/config/session.php';

require_docente();

try {
    if (request_method() !== 'POST' && request_method() !== 'PATCH') {
        json_response(['ok' => false, 'message' => 'Método no permitido.'], 405);
    }

    $id = (int) ($_GET['id'] ?? 0);
    if ($id <= 0) {
        json_response(['ok' => false, 'message' => 'Falta la actividad.'], 422);
    }

    json_response([
        'ok' => true,
        'data' => (new ContenidoService())->cambiarEstadoActividad($id, read_json_body()),
    ]);
} catch (InvalidArgumentException $exception) {
    json_response(['ok' => false, 'message' => $exception->getMessage()], 422);
} catch (Throwable $exception) {
    json_response(['ok' => false, 'message' => 'No se pudo cambiar el estado de la actividad.'], 500);
}
