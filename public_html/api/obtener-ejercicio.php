<?php

declare(strict_types=1);

require_once dirname(__DIR__, 2) . '/app_private/services/ActividadService.php';
require_once dirname(__DIR__, 2) . '/app_private/services/EjercicioService.php';

try {
    $actividadId = (int) ($_GET['actividad_id'] ?? 0);
    $intentoId = (int) ($_GET['intento_id'] ?? 0);
    $alumnoId = (int) ($_GET['student_id'] ?? $_GET['alumno_id'] ?? 0);

    if ($actividadId > 0) {
        json_response([
            'ok' => true,
            'data' => (new EjercicioService())->listarPorActividad($actividadId, $intentoId > 0 ? $intentoId : null),
        ]);
    }

    json_response([
        'ok' => true,
        'data' => (new ActividadService())->listar($alumnoId > 0 ? $alumnoId : null),
    ]);
} catch (Throwable $exception) {
    json_response(['ok' => false, 'message' => 'No se pudieron obtener los ejercicios.'], 500);
}
