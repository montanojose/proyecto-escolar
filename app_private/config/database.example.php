<?php

declare(strict_types=1);

require_once __DIR__ . '/app.php';

function db(): PDO
{
    static $pdo = null;

    if ($pdo instanceof PDO) {
        return $pdo;
    }

    $host = 'localhost';
    $port = '3306';
    $name = 'NOMBRE_BASE_DATOS';
    $user = 'USUARIO_BASE_DATOS';
    $pass = 'CLAVE_BASE_DATOS';

    $dsn = "mysql:host={$host};port={$port};dbname={$name};charset=utf8mb4";

    try {
        $pdo = new PDO($dsn, $user, $pass, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]);
    } catch (PDOException $exception) {
        json_response([
            'ok' => false,
            'message' => 'No se pudo conectar con la base de datos.',
        ], 500);
    }

    return $pdo;
}
