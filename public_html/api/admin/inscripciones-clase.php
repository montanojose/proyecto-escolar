<?php

declare(strict_types=1);

require_once dirname(__DIR__, 3) . '/app_private/config/session.php';

require_docente();

try {
    $service = new DocenteService();

    if (request_method() === 'GET') {
        json_response(['ok' => true, 'data' => $service->listarInscripciones(docente_actual_id())]);
    }

    if (request_method() === 'PATCH' || request_method() === 'PUT') {
        $id = (int) ($_GET['id'] ?? 0);
        if ($id <= 0) {
            json_response(['ok' => false, 'message' => 'Falta la inscripción.'], 422);
        }

        $body = read_json_body();
        json_response(['ok' => true, 'data' => $service->cambiarEstadoInscripcion(docente_actual_id(), $id, (string) ($body['estado'] ?? ''))]);
    }

    json_response(['ok' => false, 'message' => 'Método no permitido.'], 405);
} catch (InvalidArgumentException $exception) {
    json_response(['ok' => false, 'message' => $exception->getMessage()], 422);
} catch (Throwable $exception) {
    json_response(['ok' => false, 'message' => 'No se pudo procesar la inscripción.'], 500);
}
