<?php

declare(strict_types=1);

require_once __DIR__ . '/app.php';
require_once dirname(__DIR__) . '/services/DocenteService.php';

const DOCENTE_DNI_AUTORIZADO = '42082348';

function start_app_session(): void
{
    if (session_status() === PHP_SESSION_ACTIVE) {
        return;
    }

    session_name('electrodesafio');
    session_set_cookie_params([
        'lifetime' => 0,
        'path' => '/',
        'secure' => (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off'),
        'httponly' => true,
        'samesite' => 'Lax',
    ]);
    session_start();
}

function normalize_dni(string $dni): string
{
    return preg_replace('/\D+/', '', $dni) ?? '';
}

function docente_autenticado(): bool
{
    start_app_session();

    return (int) ($_SESSION['docente_id'] ?? 0) > 0;
}

function docente_actual(): ?array
{
    start_app_session();

    $docente = $_SESSION['docente'] ?? null;
    return is_array($docente) ? $docente : null;
}

function docente_actual_id(): int
{
    start_app_session();

    return (int) ($_SESSION['docente_id'] ?? 0);
}

function require_docente(): void
{
    if (!docente_autenticado()) {
        json_response(['ok' => false, 'message' => 'Acceso docente no autorizado.'], 401);
    }
}

function iniciar_sesion_docente(string $dni): bool
{
    $docente = (new DocenteService())->loginPorDni($dni);
    if (!$docente) {
        return false;
    }

    start_app_session();
    session_regenerate_id(true);
    $_SESSION['docente_id'] = (int) $docente['id'];
    $_SESSION['docente_dni'] = (string) $docente['dni'];
    $_SESSION['docente'] = $docente;
    $_SESSION['docente_autenticado_en'] = date('Y-m-d H:i:s');

    return true;
}

function cerrar_sesion_docente(): void
{
    start_app_session();
    $_SESSION = [];

    if (ini_get('session.use_cookies')) {
        $params = session_get_cookie_params();
        setcookie(session_name(), '', time() - 42000, $params['path'], $params['domain'] ?? '', $params['secure'], $params['httponly']);
    }

    session_destroy();
}
