<?php

ini_set('display_errors', '1');
ini_set('display_startup_errors', '1');
error_reporting(E_ALL);

echo "<h1>Debug ElectroDesafio</h1>";
echo "<p>PHP version: " . PHP_VERSION . "</p>";

$appPrivate = dirname(__DIR__) . '/app_private/config/database.php';

echo "<p>Buscando database.php en:</p>";
echo "<pre>" . htmlspecialchars($appPrivate) . "</pre>";

if (!file_exists($appPrivate)) {
    die("<h2>No existe database.php en esa ruta</h2>");
}

require_once $appPrivate;

try {
    $pdo = db();

    echo "<h2>Conexion OK</h2>";

    $tablas = $pdo->query("SHOW TABLES")->fetchAll(PDO::FETCH_COLUMN);
    echo "<p>Tablas: " . count($tablas) . "</p>";

    $actividades = $pdo->query("SELECT COUNT(*) FROM actividades")->fetchColumn();
    echo "<p>Actividades: " . (int) $actividades . "</p>";

    $ejercicios = $pdo->query("SELECT COUNT(*) FROM ejercicios")->fetchColumn();
    echo "<p>Ejercicios: " . (int) $ejercicios . "</p>";

} catch (Throwable $e) {
    echo "<h2>Error</h2>";
    echo "<pre>" . htmlspecialchars($e->getMessage()) . "</pre>";
}