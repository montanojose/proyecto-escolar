<?php

declare(strict_types=1);

require_once dirname(__DIR__, 2) . '/app_private/services/DocenteService.php';

try {
    require_post();

    json_response([
        'ok' => true,
        'data' => (new DocenteService())->registrarAlumnoEnClase(read_json_body()),
    ], 201);
} catch (InvalidArgumentException $exception) {
    json_response(['ok' => false, 'message' => $exception->getMessage()], 422);
} catch (Throwable $exception) {
    json_response(['ok' => false, 'message' => 'No se pudo registrar el alumno.'], 500);
}
