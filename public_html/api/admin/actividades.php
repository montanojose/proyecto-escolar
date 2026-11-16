<?php

declare(strict_types=1);

require_once dirname(__DIR__, 3) . '/app_private/services/ContenidoService.php';
require_once dirname(__DIR__, 3) . '/app_private/config/session.php';

require_docente();

try {
    $service = new ContenidoService();
    $method = request_method();
    $id = (int) ($_GET['id'] ?? 0);

    if ($method === 'GET') {
        json_response(['ok' => true, 'data' => $service->listarActividadesAdmin()]);
    }

    if ($method === 'POST') {
        json_response(['ok' => true, 'data' => $service->guardarActividad(read_json_body())], 201);
    }

    if ($method === 'PUT' || $method === 'PATCH') {
        if ($id <= 0) {
            json_response(['ok' => false, 'message' => 'Falta la actividad a editar.'], 422);
        }
        json_response(['ok' => true, 'data' => $service->guardarActividad(read_json_body(), $id)]);
    }

    json_response(['ok' => false, 'message' => 'Método no permitido.'], 405);
} catch (InvalidArgumentException $exception) {
    json_response(['ok' => false, 'message' => $exception->getMessage()], 422);
} catch (Throwable $exception) {
    json_response(['ok' => false, 'message' => 'No se pudo procesar la actividad.'], 500);
}
