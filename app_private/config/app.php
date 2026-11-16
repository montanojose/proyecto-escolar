<?php

declare(strict_types=1);

const APP_NAME = 'ElectroDesafio';
const APP_TIMEZONE = 'America/Argentina/Buenos_Aires';

date_default_timezone_set(APP_TIMEZONE);

function app_base_path(string $path = ''): string
{
    $base = dirname(__DIR__, 2);
    return $path === '' ? $base : $base . DIRECTORY_SEPARATOR . ltrim($path, DIRECTORY_SEPARATOR);
}

function json_response(array $payload, int $status = 200): void
{
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    header('Cache-Control: no-store');
    echo json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function read_json_body(): array
{
    $raw = file_get_contents('php://input');
    if ($raw === false || trim($raw) === '') {
        return [];
    }

    $data = json_decode($raw, true);
    if (!is_array($data)) {
        json_response(['ok' => false, 'message' => 'El cuerpo JSON no es válido.'], 400);
    }

    return $data;
}

function require_post(): void
{
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        json_response(['ok' => false, 'message' => 'Método no permitido.'], 405);
    }
}

function request_method(): string
{
    return strtoupper((string) ($_SERVER['REQUEST_METHOD'] ?? 'GET'));
}

function input_int(array $data, string $key, int $default = 0): int
{
    return isset($data[$key]) ? (int) $data[$key] : $default;
}

function input_bool(array $data, string $key, bool $default = false): bool
{
    if (!array_key_exists($key, $data)) {
        return $default;
    }

    return filter_var($data[$key], FILTER_VALIDATE_BOOLEAN, FILTER_NULL_ON_FAILURE) ?? $default;
}

function input_string(array $data, string $key, string $default = ''): string
{
    return trim((string) ($data[$key] ?? $default));
}
