<?php

declare(strict_types=1);

require_once dirname(__DIR__) . '/app_private/config/database.php';
require_once dirname(__DIR__) . '/app_private/services/DocenteService.php';
require_once dirname(__DIR__) . '/app_private/services/ActividadClaseService.php';
require_once dirname(__DIR__) . '/app_private/services/ActividadService.php';

$docentes = new DocenteService();
$actividadesClase = new ActividadClaseService();
$actividades = new ActividadService();

$docente = $docentes->loginPorDni('42082348');
if (!$docente) {
    throw new RuntimeException('No se pudo iniciar con el docente semilla.');
}

db()->exec(
    "DELETE cd
     FROM clases_docente cd
     INNER JOIN escuelas e ON e.id = cd.escuela_id
     WHERE e.nombre = 'Escuela Test Actividades Clase'"
);
db()->prepare('DELETE FROM alumnos WHERE dni = ?')->execute(['99000456']);
db()->prepare('DELETE FROM escuelas WHERE nombre = ?')->execute(['Escuela Test Actividades Clase']);

$clase = $docentes->crearClase((int) $docente['id'], [
    'escuela' => 'Escuela Test Actividades Clase',
    'materia' => 'Matematica Test',
    'curso' => 'Curso Actividades Clase',
    'anio' => 5,
    'division' => 'B',
]);

$registro = $docentes->registrarAlumnoEnClase([
    'nombre' => 'Alumno',
    'apellido' => 'Actividad Clase',
    'dni' => '99000456',
    'clave' => '99000456',
    'codigo' => (string) $clase['codigo'],
]);

$inscripciones = $docentes->listarInscripciones((int) $docente['id']);
$inscripcionId = 0;
foreach ($inscripciones as $inscripcion) {
    if ((string) $inscripcion['dni'] === '99000456') {
        $inscripcionId = (int) $inscripcion['id'];
        break;
    }
}
$docentes->cambiarEstadoInscripcion((int) $docente['id'], $inscripcionId, 'validada');

$actividadId = (int) db()->query('SELECT id FROM actividades WHERE visible_alumno = 1 ORDER BY id LIMIT 1')->fetchColumn();
$asignacion = $actividadesClase->asignar((int) $docente['id'], (int) $clase['id'], $actividadId, [
    'visible_alumno' => true,
    'acceso_habilitado' => true,
    'puntaje_habilitado' => true,
    'estado' => 'Disponible',
]);

$alumnoId = (int) db()->query("SELECT id FROM alumnos WHERE dni = '99000456' LIMIT 1")->fetchColumn();
$listado = $actividades->listar($alumnoId);
$asignada = array_values(array_filter($listado, fn (array $item): bool => (int) $item['classActivityId'] === (int) $asignacion['id']));

echo json_encode([
    'codigo_clase' => $clase['codigo'],
    'registro' => $registro['status'],
    'actividad_clase_id' => (int) $asignacion['id'],
    'actividades_alumno' => count($listado),
    'asignacion_visible' => count($asignada) === 1,
], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT) . PHP_EOL;

db()->prepare('DELETE FROM alumnos WHERE dni = ?')->execute(['99000456']);
db()->exec(
    "DELETE cd
     FROM clases_docente cd
     INNER JOIN escuelas e ON e.id = cd.escuela_id
     WHERE e.nombre = 'Escuela Test Actividades Clase'"
);
db()->prepare('DELETE FROM escuelas WHERE nombre = ?')->execute(['Escuela Test Actividades Clase']);
