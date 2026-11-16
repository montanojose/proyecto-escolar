<?php

declare(strict_types=1);

require_once dirname(__DIR__) . '/app_private/config/database.php';
require_once dirname(__DIR__) . '/app_private/services/DocenteService.php';

$service = new DocenteService();

db()->exec(
    "DELETE cd
     FROM clases_docente cd
     INNER JOIN escuelas e ON e.id = cd.escuela_id
     WHERE e.nombre = 'Escuela Test Codex'"
);
db()->prepare('DELETE FROM alumnos WHERE dni = ?')->execute(['99000123']);
db()->prepare('DELETE FROM escuelas WHERE nombre = ?')->execute(['Escuela Test Codex']);

$docente = $service->loginPorDni('42082348');
if (!$docente) {
    throw new RuntimeException('No se pudo iniciar con el docente semilla.');
}

$clase = $service->crearClase((int) $docente['id'], [
    'escuela' => 'Escuela Test Codex',
    'materia' => 'Materia Test Codex',
    'curso' => 'Curso Test Codex',
    'anio' => 5,
    'division' => 'A',
]);

$registro = $service->registrarAlumnoEnClase([
    'nombre' => 'Alumno',
    'apellido' => 'Test Codex',
    'dni' => '99000123',
    'clave' => '99000123',
    'codigo' => (string) $clase['codigo'],
]);

$inscripciones = $service->listarInscripciones((int) $docente['id']);
$inscripcionId = 0;
foreach ($inscripciones as $inscripcion) {
    if ((string) $inscripcion['dni'] === '99000123') {
        $inscripcionId = (int) $inscripcion['id'];
        break;
    }
}

if ($inscripcionId <= 0) {
    throw new RuntimeException('No se encontro la inscripcion pendiente.');
}

$service->cambiarEstadoInscripcion((int) $docente['id'], $inscripcionId, 'validada');

$stmt = db()->prepare(
    'SELECT COUNT(*)
     FROM alumnos a
     INNER JOIN inscripciones i ON i.alumno_id = a.id AND i.activo = 1
     WHERE a.dni = ?'
);
$stmt->execute(['99000123']);

echo json_encode([
    'docente' => $docente['dni'],
    'codigo_clase' => $clase['codigo'],
    'registro' => $registro['status'],
    'inscripcion_validada' => (int) $stmt->fetchColumn() === 1,
], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT) . PHP_EOL;

db()->prepare('DELETE FROM alumnos WHERE dni = ?')->execute(['99000123']);
db()->exec(
    "DELETE cd
     FROM clases_docente cd
     INNER JOIN escuelas e ON e.id = cd.escuela_id
     WHERE e.nombre = 'Escuela Test Codex'"
);
db()->prepare('DELETE FROM escuelas WHERE nombre = ?')->execute(['Escuela Test Codex']);
