<?php

declare(strict_types=1);

require_once dirname(__DIR__, 3) . '/app_private/config/session.php';

try {
    require_post();
    cerrar_sesion_docente();
    json_response(['ok' => true, 'data' => ['authorized' => false]]);
} catch (Throwable $exception) {
    json_response(['ok' => false, 'message' => 'No se pudo cerrar la sesion docente.'], 500);
}
