<?php

declare(strict_types=1);

require_once dirname(__DIR__, 3) . '/app_private/services/ContenidoService.php';
require_once dirname(__DIR__, 3) . '/app_private/config/session.php';

require_docente();

try {
    $service = new ContenidoService();

    json_response([
        'ok' => true,
        'data' => $service->planillaPuntos((int) ($_GET['curso_id'] ?? 0) ?: null),
    ]);
} catch (Throwable $exception) {
    json_response(['ok' => false, 'message' => 'No se pudo obtener la planilla de puntos.'], 500);
}
