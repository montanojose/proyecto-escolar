<?php

declare(strict_types=1);

require_once dirname(__DIR__, 3) . '/app_private/config/session.php';

require_docente();

try {
    $service = new DocenteService();

    if (request_method() === 'GET') {
        json_response(['ok' => true, 'data' => $service->listarClases(docente_actual_id())]);
    }

    if (request_method() === 'POST') {
        json_response(['ok' => true, 'data' => $service->crearClase(docente_actual_id(), read_json_body())], 201);
    }

    json_response(['ok' => false, 'message' => 'Método no permitido.'], 405);
} catch (InvalidArgumentException $exception) {
    json_response(['ok' => false, 'message' => $exception->getMessage()], 422);
} catch (Throwable $exception) {
    json_response(['ok' => false, 'message' => 'No se pudo procesar la clase.'], 500);
}
