<?php

declare(strict_types=1);

require_once dirname(__DIR__) . '/app_private/config/database.php';
require_once dirname(__DIR__) . '/app_private/services/MatematicaRacionalService.php';

$pdo = db();
$service = new MatematicaRacionalService();
$ref = new ReflectionClass($service);
$tasksMethod = $ref->getMethod('tasks');
$tasksMethod->setAccessible(true);

$prefix = '99088';
$studentCount = 20;
$report = [
    'activityId' => null,
    'students' => [],
    'versions' => [],
    'taskStructureHashes' => [],
    'bugs' => [],
    'reusableChecks' => [],
];

function fail_report(array &$report, string $message): void
{
    $report['bugs'][] = $message;
}

function cleanup_test_students(PDO $pdo, string $prefix): void
{
    $stmt = $pdo->prepare('DELETE FROM alumnos WHERE dni LIKE ?');
    $stmt->execute([$prefix . '%']);
}

function insert_attempt(PDO $pdo, int $studentId, int $activityId): int
{
    $stmt = $pdo->prepare(
        "INSERT INTO intentos (alumno_id, actividad_id, modo, estado, iniciado_en, ultimo_acceso_en)
         VALUES (?, ?, 'practica', 'iniciado', NOW(), NOW())"
    );
    $stmt->execute([$studentId, $activityId]);

    return (int) $pdo->lastInsertId();
}

function current_task(array $tasks, array $activity): array
{
    return $tasks[(int) $activity['currentTaskIndex']] ?? ['type' => 'completed'];
}

try {
    cleanup_test_students($pdo, $prefix);

    $stmt = $pdo->prepare(
        "SELECT a.id
         FROM actividades a
         INNER JOIN contenedores_actividad ca ON ca.id = a.contenedor_id
         INNER JOIN temas t ON t.id = ca.tema_id
         WHERE t.nombre = 'Matemática'
           AND a.titulo = 'Aplicaciones de la función racional: calcular, observar e interpretar'
         LIMIT 1"
    );
    $stmt->execute();
    $activityId = (int) ($stmt->fetchColumn() ?: 0);
    if ($activityId <= 0) {
        throw new RuntimeException('No se encontró la actividad de Matemática.');
    }
    $report['activityId'] = $activityId;

    for ($i = 1; $i <= $studentCount; $i++) {
        $dni = $prefix . str_pad((string) $i, 5, '0', STR_PAD_LEFT);
        $stmt = $pdo->prepare('INSERT INTO alumnos (dni, nombre) VALUES (?, ?)');
        $stmt->execute([$dni, 'Alumno Prueba Matematica ' . $i]);
        $studentId = (int) $pdo->lastInsertId();
        $attemptId = insert_attempt($pdo, $studentId, $activityId);

        $activity = $service->iniciar($activityId, $studentId, $attemptId);
        $versionKey = $activity['version']['a'] . ',' . $activity['version']['b'];
        $report['versions'][$versionKey] = ($report['versions'][$versionKey] ?? 0) + 1;

        $restored = $service->obtener($activityId, $studentId);
        if ($restored['version'] !== $activity['version'] || $restored['currentTaskIndex'] !== $activity['currentTaskIndex']) {
            fail_report($report, "Alumno {$i}: la restauración inicial no coincide.");
        }

        $tasks = $tasksMethod->invoke($service, (int) $activity['version']['a'], (int) $activity['version']['b']);
        $report['taskStructureHashes'][] = sha1(implode('|', array_map(fn (array $task): string => $task['type'] . ':' . $task['id'], $tasks)));
        $calcCount = 0;

        while (!$activity['completed']) {
            $task = current_task($tasks, $activity);
            if (($task['type'] ?? '') === 'calc') {
                $calcCount++;
                $activity = $service->verificar($activityId, $studentId, $attemptId, [
                    'answer' => (string) $task['answer'],
                    'elapsedSeconds' => 10 + $calcCount,
                ]);

                if (empty($activity['correct'])) {
                    fail_report($report, "Alumno {$i}: respuesta correcta rechazada en {$task['id']}.");
                    break;
                }

                $route = null;
                foreach ($activity['routes'] as $candidate) {
                    if ($candidate['key'] === $task['routeKey']) {
                        $route = $candidate;
                        break;
                    }
                }
                $expectedRows = count($route['key'] === 'coulomb' ? [1] : []) + count(array_filter(
                    array_slice($tasks, 0, (int) $activity['currentTaskIndex']),
                    fn (array $done): bool => ($done['type'] ?? '') === 'calc' && ($done['routeKey'] ?? '') === $task['routeKey']
                ));
                if ($route && count($route['rows']) !== $expectedRows) {
                    fail_report($report, "Alumno {$i}: filas del recorrido {$route['key']} esperadas {$expectedRows}, obtenidas " . count($route['rows']) . '.');
                }
            } elseif (($task['type'] ?? '') === 'choice' || ($task['type'] ?? '') === 'closing') {
                $activity = $service->verificar($activityId, $studentId, $attemptId, [
                    'optionIndex' => (int) $task['correct'],
                    'elapsedSeconds' => 60,
                ]);
                if (empty($activity['correct'])) {
                    fail_report($report, "Alumno {$i}: opción correcta rechazada en {$task['id']}.");
                    break;
                }
            } else {
                fail_report($report, "Alumno {$i}: tarea desconocida.");
                break;
            }
        }

        $stmt = $pdo->prepare('SELECT estado, correctas, cantidad_respuestas FROM intentos WHERE id = ?');
        $stmt->execute([$attemptId]);
        $attempt = $stmt->fetch();
        if (($attempt['estado'] ?? '') !== 'finalizado' || (int) $attempt['correctas'] !== 27 || (int) $attempt['cantidad_respuestas'] !== 27) {
            fail_report($report, "Alumno {$i}: intento final inesperado " . json_encode($attempt, JSON_UNESCAPED_UNICODE) . '.');
        }

        $report['students'][] = [
            'n' => $i,
            'dni' => $dni,
            'version' => $versionKey,
            'completed' => (bool) $activity['completed'],
            'correctCalculations' => (int) $activity['correctCalculations'],
            'attempts' => (int) $activity['attempts'],
        ];

    }

    foreach (array_slice($report['students'], 0, 3) as $student) {
        $stmt = $pdo->prepare('SELECT id FROM alumnos WHERE dni = ? LIMIT 1');
        $stmt->execute([$student['dni']]);
        $studentId = (int) ($stmt->fetchColumn() ?: 0);
        $newAttemptId = insert_attempt($pdo, $studentId, $activityId);
        $restart = $service->iniciar($activityId, $studentId, $newAttemptId);
        $report['reusableChecks'][] = [
            'student' => $student['n'],
            'previousVersion' => $student['version'],
            'newVersion' => $restart['version']['a'] . ',' . $restart['version']['b'],
            'currentTaskIndex' => (int) $restart['currentTaskIndex'],
            'completed' => (bool) $restart['completed'],
        ];
        if ((int) $restart['currentTaskIndex'] !== 0 || (bool) $restart['completed']) {
            fail_report($report, "Alumno {$student['n']}: no reinició correctamente tras completar.");
        }
    }

    $report['uniqueVersions'] = count($report['versions']);
    $report['sameStructure'] = count(array_unique($report['taskStructureHashes'])) === 1;
    $report['ok'] = count($report['bugs']) === 0;
} finally {
    cleanup_test_students($pdo, $prefix);
}

echo json_encode($report, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES), PHP_EOL;
