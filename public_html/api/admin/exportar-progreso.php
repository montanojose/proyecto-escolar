<?php

declare(strict_types=1);

require_once dirname(__DIR__, 3) . '/app_private/services/ContenidoService.php';
require_once dirname(__DIR__, 3) . '/app_private/config/session.php';

require_docente();

try {
    if (request_method() !== 'GET') {
        json_response(['ok' => false, 'message' => 'Método no permitido.'], 405);
    }

    $rows = (new ContenidoService())->listarProgreso(
        (int) ($_GET['curso_id'] ?? 0) ?: null,
        (int) ($_GET['actividad_id'] ?? 0) ?: null,
        isset($_GET['estado']) && $_GET['estado'] !== '' ? (string) $_GET['estado'] : null,
        filter_var($_GET['pendientes'] ?? false, FILTER_VALIDATE_BOOLEAN)
    );

    header('Content-Type: text/csv; charset=utf-8');
    header('Content-Disposition: attachment; filename="progreso.csv"');

    $out = fopen('php://output', 'w');
    fputcsv($out, ['Alumno', 'DNI', 'Curso', 'Actividad', 'Modo', 'Estado', 'Respuestas', 'Correctas', 'Puntos', 'Duracion segundos', 'Inicio', 'Finalizacion']);

    foreach ($rows as $row) {
        fputcsv($out, [
            $row['alumno'],
            $row['dni'],
            $row['curso'],
            $row['actividad'],
            $row['modo'],
            $row['estado'],
            $row['cantidad_respuestas'],
            $row['correctas'],
            $row['puntaje'],
            $row['duracion_segundos'],
            $row['iniciado_en'],
            $row['finalizado_en'],
        ]);
    }

    fclose($out);
} catch (Throwable $exception) {
    json_response(['ok' => false, 'message' => 'No se pudo exportar el progreso.'], 500);
}
