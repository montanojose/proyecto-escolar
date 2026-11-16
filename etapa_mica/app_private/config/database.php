<?php

declare(strict_types=1);

require_once __DIR__ . '/app.php';

function mica_db(): PDO
{
    static $pdo = null;

    if ($pdo instanceof PDO) {
        return $pdo;
    }

    $host = getenv('MICA_DB_HOST') ?: '127.0.0.1';
    $port = getenv('MICA_DB_PORT') ?: '3306';
    $name = getenv('MICA_DB_NAME') ?: 'materias_mica';
    $user = getenv('MICA_DB_USER') ?: 'root';
    $pass = getenv('MICA_DB_PASS') ?: '';

    $dsn = "mysql:host={$host};port={$port};dbname={$name};charset=utf8mb4";

    try {
        $pdo = new PDO($dsn, $user, $pass, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]);
    } catch (PDOException $exception) {
        mica_json_response([
            'ok' => false,
            'message' => 'No se pudo conectar con la base de datos de la etapa Mica.',
        ], 500);
    }

    return $pdo;
}
