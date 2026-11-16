<?php

declare(strict_types=1);

require_once dirname(__DIR__, 2) . '/app_private/config/database.php';

require_post();

try {
    $pdo = db();
    $dni = '00000000';

    $stmt = $pdo->prepare(
        "INSERT INTO alumnos (dni, nombre, fecha_nacimiento)
         VALUES (?, 'INVITADO, MODO DEMO', NULL)
         ON DUPLICATE KEY UPDATE nombre = VALUES(nombre)"
    );
    $stmt->execute([$dni]);

    $stmt = $pdo->prepare('SELECT id, dni, nombre FROM alumnos WHERE dni = ? LIMIT 1');
    $stmt->execute([$dni]);
    $alumno = $stmt->fetch();

    json_response([
        'ok' => true,
        'data' => [
            'student' => [
                'id' => (int) $alumno['id'],
                'dni' => (string) $alumno['dni'],
                'name' => (string) $alumno['nombre'],
                'guest' => true,
            ],
        ],
    ]);
} catch (Throwable $exception) {
    json_response(['ok' => false, 'message' => 'No se pudo iniciar el modo invitado.'], 500);
}
