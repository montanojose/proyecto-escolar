<?php

declare(strict_types=1);

require_once dirname(__DIR__, 3) . '/app_private/services/ContenidoService.php';
require_once dirname(__DIR__, 3) . '/app_private/config/session.php';

require_docente();

try {
    if (request_method() !== 'GET') {
        json_response(['ok' => false, 'message' => 'Método no permitido.'], 405);
    }

    $alumnoId = (int) ($_GET['alumno_id'] ?? 0);
    if ($alumnoId <= 0) {
        json_response(['ok' => false, 'message' => 'Falta el alumno.'], 422);
    }

    json_response([
        'ok' => true,
        'data' => (new ContenidoService())->resumenAlumno($alumnoId),
    ]);
} catch (InvalidArgumentException $exception) {
    json_response(['ok' => false, 'message' => $exception->getMessage()], 422);
} catch (Throwable $exception) {
    json_response(['ok' => false, 'message' => 'No se pudo obtener el resumen del alumno.'], 500);
}
