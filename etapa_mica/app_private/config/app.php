<?php

declare(strict_types=1);

const MICA_APP_NAME = 'Materias Mica';
const MICA_APP_TIMEZONE = 'America/Argentina/Buenos_Aires';

date_default_timezone_set(MICA_APP_TIMEZONE);

function mica_base_path(string $path = ''): string
{
    $base = dirname(__DIR__, 2);
    return $path === '' ? $base : $base . DIRECTORY_SEPARATOR . ltrim($path, DIRECTORY_SEPARATOR);
}

function mica_json_response(array $payload, int $status = 200): void
{
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    header('Cache-Control: no-store');
    echo json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function mica_read_json_body(): array
{
    $raw = file_get_contents('php://input');
    if ($raw === false || trim($raw) === '') {
        return [];
    }

    $data = json_decode($raw, true);
    if (!is_array($data)) {
        mica_json_response(['ok' => false, 'message' => 'El cuerpo JSON no es valido.'], 400);
    }

    return $data;
}
