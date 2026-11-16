<?php

declare(strict_types=1);

require_once dirname(__DIR__, 2) . '/app_private/services/LenguaActividadService.php';

try {
    $service = new LenguaActividadService();
    $method = request_method();

    if ($method === 'GET') {
        $actividadId = (int) ($_GET['actividad_id'] ?? 0);
        $alumnoId = (int) ($_GET['student_id'] ?? $_GET['alumno_id'] ?? 0);

        if ($actividadId <= 0 || $alumnoId <= 0) {
            json_response(['ok' => false, 'message' => 'Faltan datos para cargar la actividad.'], 422);
        }

        json_response(['ok' => true, 'data' => $service->obtener($actividadId, $alumnoId)]);
    }

    if ($method === 'POST') {
        require_post();
        $body = read_json_body();
        $actividadId = (int) ($body['activityId'] ?? $body['actividad_id'] ?? 0);
        $alumnoId = (int) ($body['studentId'] ?? $body['alumno_id'] ?? 0);
        $intentoId = (int) ($body['attemptId'] ?? $body['intento_id'] ?? 0);
        $paso = (string) ($body['step'] ?? $body['paso'] ?? '');
        $seleccion = $body['selection'] ?? $body['seleccion'] ?? [];
        $duracion = (int) ($body['elapsedSeconds'] ?? $body['duracion_segundos'] ?? 0);

        if ($actividadId <= 0 || $alumnoId <= 0 || $intentoId <= 0 || !is_array($seleccion)) {
            json_response(['ok' => false, 'message' => 'Faltan datos para verificar la respuesta.'], 422);
        }

        json_response([
            'ok' => true,
            'data' => $service->verificar($actividadId, $alumnoId, $intentoId, $paso, $seleccion, $duracion),
        ]);
    }

    json_response(['ok' => false, 'message' => 'Metodo no permitido.'], 405);
} catch (InvalidArgumentException $exception) {
    json_response(['ok' => false, 'message' => $exception->getMessage()], 422);
} catch (Throwable $exception) {
    json_response(['ok' => false, 'message' => 'No se pudo procesar la actividad de Lengua.'], 500);
}
