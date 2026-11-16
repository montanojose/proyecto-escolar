<?php

declare(strict_types=1);

require_once dirname(__DIR__, 2) . '/app_private/services/PuntosService.php';
require_once dirname(__DIR__, 2) . '/app_private/config/session.php';

require_docente();

try {
    json_response([
        'ok' => true,
        'data' => (new PuntosService())->resumenAdmin(),
    ]);
} catch (Throwable $exception) {
    json_response(['ok' => false, 'message' => 'No se pudieron obtener los resultados.'], 500);
}
