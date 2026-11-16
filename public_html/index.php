<?php

declare(strict_types=1);

$assetBase = './assets/app/assets/';
$cssFile = 'main.css';
$jsFile = 'main.js';
$cssVersion = file_exists(__DIR__ . '/assets/app/assets/' . $cssFile)
    ? (string) filemtime(__DIR__ . '/assets/app/assets/' . $cssFile)
    : (string) time();
$jsVersion = file_exists(__DIR__ . '/assets/app/assets/' . $jsFile)
    ? (string) filemtime(__DIR__ . '/assets/app/assets/' . $jsFile)
    : (string) time();

header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
header('Pragma: no-cache');
?>
<!doctype html>
<html lang="es">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ElectroDesafio</title>
    <link rel="stylesheet" href="<?= $assetBase . $cssFile . '?v=' . $cssVersion ?>">
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="<?= $assetBase . $jsFile . '?v=' . $jsVersion ?>"></script>
  </body>
</html>
