<?php

declare(strict_types=1);

$cssVersion = file_exists(__DIR__ . '/assets/css/main.css')
    ? (string) filemtime(__DIR__ . '/assets/css/main.css')
    : (string) time();
$jsVersion = file_exists(__DIR__ . '/assets/js/main.js')
    ? (string) filemtime(__DIR__ . '/assets/js/main.js')
    : (string) time();

header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
header('Pragma: no-cache');
?>
<!doctype html>
<html lang="es">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Materias Mica</title>
    <link rel="stylesheet" href="./assets/css/main.css?v=<?= $cssVersion ?>">
  </head>
  <body>
    <main class="shell">
      <section class="intro" aria-labelledby="titulo">
        <p class="eyebrow">Etapa independiente</p>
        <h1 id="titulo">Lengua, Historia y Ciencias Naturales</h1>
        <p class="lead">
          Este espacio esta separado de ElectroDesafio para cargar actividades, estilos y datos sin afectar la etapa actual.
        </p>
      </section>

      <section class="subjects" aria-label="Materias">
        <article class="subject-card subject-card--lengua">
          <span class="subject-card__tag">Lengua</span>
          <h2>Lectura y escritura</h2>
          <p>Comprension de textos, consignas, producciones y revision docente.</p>
          <a href="#" aria-disabled="true">Preparar actividades</a>
        </article>

        <article class="subject-card subject-card--historia">
          <span class="subject-card__tag">Historia</span>
          <h2>Procesos historicos</h2>
          <p>Lineas de tiempo, fuentes, preguntas guiadas y trabajos practicos.</p>
          <a href="#" aria-disabled="true">Preparar actividades</a>
        </article>

        <article class="subject-card subject-card--naturales">
          <span class="subject-card__tag">Ciencias Naturales</span>
          <h2>Ambiente y ciencia</h2>
          <p>Temas, experiencias, cuestionarios y seguimiento por curso.</p>
          <a href="#" aria-disabled="true">Preparar actividades</a>
        </article>
      </section>
    </main>

    <script src="./assets/js/main.js?v=<?= $jsVersion ?>"></script>
  </body>
</html>
