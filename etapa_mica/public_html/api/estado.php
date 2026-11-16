<?php

declare(strict_types=1);

require_once __DIR__ . '/../../app_private/config/database.php';

try {
    $db = mica_db();
    $materias = $db->query('SELECT id, nombre, slug FROM materias ORDER BY nombre')->fetchAll();

    mica_json_response([
        'ok' => true,
        'data' => [
            'app' => MICA_APP_NAME,
            'database' => 'conectada',
            'materias' => $materias,
        ],
    ]);
} catch (Throwable $exception) {
    mica_json_response([
        'ok' => false,
        'message' => 'La API de la etapa Mica responde, pero falta revisar la base de datos.',
    ], 500);
}
