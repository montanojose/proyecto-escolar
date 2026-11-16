<?php

declare(strict_types=1);

require_once dirname(__DIR__, 3) . '/app_private/config/session.php';
require_once dirname(__DIR__, 3) . '/app_private/services/ActividadClaseService.php';

require_docente();

try {
    $service = new ActividadClaseService();
    $method = request_method();
    $claseId = (int) ($_GET['clase_id'] ?? 0);
    $id = (int) ($_GET['id'] ?? 0);

    if ($method === 'GET') {
        json_response(['ok' => true, 'data' => $service->listarCatalogo(docente_actual_id(), $claseId > 0 ? $claseId : null)]);
    }

    if ($method === 'POST') {
        $body = read_json_body();
        $bodyClaseId = (int) ($body['clase_id'] ?? $claseId);
        $actividadId = (int) ($body['actividad_id'] ?? $body['activityId'] ?? 0);
        if ($bodyClaseId <= 0 || $actividadId <= 0) {
            json_response(['ok' => false, 'message' => 'Falta clase o actividad.'], 422);
        }

        json_response(['ok' => true, 'data' => $service->asignar(docente_actual_id(), $bodyClaseId, $actividadId, $body)], 201);
    }

    if ($method === 'PATCH' || $method === 'PUT') {
        if ($id <= 0) {
            json_response(['ok' => false, 'message' => 'Falta la asignación.'], 422);
        }

        json_response(['ok' => true, 'data' => $service->cambiarEstado(docente_actual_id(), $id, read_json_body())]);
    }

    if ($method === 'DELETE') {
        if ($id <= 0) {
            json_response(['ok' => false, 'message' => 'Falta la asignación.'], 422);
        }

        json_response(['ok' => true, 'data' => $service->desasignar(docente_actual_id(), $id)]);
    }

    json_response(['ok' => false, 'message' => 'Método no permitido.'], 405);
} catch (InvalidArgumentException $exception) {
    json_response(['ok' => false, 'message' => $exception->getMessage()], 422);
} catch (Throwable $exception) {
    json_response(['ok' => false, 'message' => 'No se pudo procesar la actividad de la clase.'], 500);
}
