<?php

declare(strict_types=1);

require_once dirname(__DIR__) . '/config/database.php';

final class MatematicaRacionalService
{
    private const TITLE = 'Aplicaciones de la función racional: calcular, observar e interpretar';
    private const ACTIVITY_TYPE = 'matematica_funcion_racional';
    private const K = 9000000000.0;

    public function iniciar(int $actividadId, int $alumnoId, int $intentoId): array
    {
        $this->asegurarActividad($actividadId);
        $pdo = db();
        $pdo->beginTransaction();

        try {
            $stmt = $pdo->prepare(
                'SELECT id, completada
                 FROM matematica_racional_progreso
                 WHERE alumno_id = ? AND actividad_id = ?
                 LIMIT 1
                 FOR UPDATE'
            );
            $stmt->execute([$alumnoId, $actividadId]);
            $row = $stmt->fetch();

            if (!$row) {
                $indices = $this->asignarIndicesEquilibrados($actividadId);
                $stmt = $pdo->prepare(
                    "INSERT INTO matematica_racional_progreso
                     (alumno_id, actividad_id, intento_id, indice_a, indice_b, tarea_actual, respuestas_json, intentos_json, iniciado_en, ultimo_acceso_en)
                     VALUES (?, ?, ?, ?, ?, 0, '{}', '{}', NOW(), NOW())"
                );
                $stmt->execute([$alumnoId, $actividadId, $intentoId, $indices['a'], $indices['b']]);
            } elseif ((int) $row['completada'] === 1) {
                $indices = $this->asignarIndicesEquilibrados($actividadId);
                $stmt = $pdo->prepare(
                    "UPDATE matematica_racional_progreso
                     SET intento_id = ?, indice_a = ?, indice_b = ?, tarea_actual = 0,
                         respuestas_json = '{}', intentos_json = '{}', completada = 0,
                         iniciado_en = NOW(), ultimo_acceso_en = NOW(), finalizado_en = NULL
                     WHERE id = ?"
                );
                $stmt->execute([$intentoId, $indices['a'], $indices['b'], (int) $row['id']]);
            } elseif ((int) $row['completada'] !== 1) {
                $stmt = $pdo->prepare(
                    'UPDATE matematica_racional_progreso
                     SET intento_id = ?, ultimo_acceso_en = NOW()
                     WHERE id = ?'
                );
                $stmt->execute([$intentoId, (int) $row['id']]);
            }

            $pdo->commit();
        } catch (Throwable $exception) {
            $pdo->rollBack();
            throw $exception;
        }

        return $this->obtener($actividadId, $alumnoId);
    }

    public function obtener(int $actividadId, int $alumnoId): array
    {
        $this->asegurarActividad($actividadId);
        $row = $this->obtenerFila($actividadId, $alumnoId);
        if (!$row) {
            throw new InvalidArgumentException('Primero hay que iniciar la actividad.');
        }

        return $this->mapear($row);
    }

    public function verificar(int $actividadId, int $alumnoId, int $intentoId, array $payload): array
    {
        $pdo = db();
        $pdo->beginTransaction();

        try {
            $row = $this->obtenerFila($actividadId, $alumnoId, true);
            if (!$row) {
                throw new InvalidArgumentException('No encontramos el avance de esta actividad.');
            }

            if ((int) $row['completada'] === 1) {
                $pdo->commit();
                return array_merge($this->mapear($row), [
                    'correct' => true,
                    'message' => 'Actividad completada.',
                ]);
            }

            $tasks = $this->tasks((int) $row['indice_a'], (int) $row['indice_b']);
            $currentIndex = (int) $row['tarea_actual'];
            $task = $tasks[$currentIndex] ?? null;
            if (!$task) {
                throw new InvalidArgumentException('No hay una tarea activa para corregir.');
            }

            $respuestas = $this->json((string) $row['respuestas_json']);
            $intentos = $this->json((string) $row['intentos_json']);
            $taskId = (string) $task['id'];
            $intentos[$taskId] = ((int) ($intentos[$taskId] ?? 0)) + 1;

            $correcta = false;
            $mensaje = 'Revisá tu cálculo';
            $respuestaGuardada = [];

            if ($task['type'] === 'calc') {
                $valor = $this->parseNumero((string) ($payload['answer'] ?? ''));
                if ($valor === null) {
                    $correcta = false;
                } else {
                    $esperado = (float) $task['answer'];
                    $correcta = $this->dentroDeTolerancia($valor, $esperado, $task);
                    $respuestaGuardada = [
                        'answer' => $valor,
                        'expected' => $esperado,
                        'x' => (float) $task['x'],
                        'y' => $esperado,
                    ];
                }
                $mensaje = $correcta ? 'Correcto: agregamos el punto al gráfico' : 'Revisá tu cálculo';
            } elseif ($task['type'] === 'choice' || $task['type'] === 'closing') {
                $opcion = (int) ($payload['optionIndex'] ?? -1);
                $correcta = $opcion === (int) $task['correct'];
                $respuestaGuardada = ['optionIndex' => $opcion];
                $mensaje = $correcta ? 'Correcto: seguimos avanzando' : 'Revisá la interpretación';
            }

            if ($correcta) {
                $respuestas[$taskId] = $respuestaGuardada;
                $currentIndex++;
            }

            $completada = $currentIndex >= count($tasks);

            $stmt = $pdo->prepare(
                'UPDATE matematica_racional_progreso
                 SET intento_id = ?, tarea_actual = ?, respuestas_json = ?, intentos_json = ?,
                     completada = ?, finalizado_en = IF(? = 1, NOW(), finalizado_en), ultimo_acceso_en = NOW()
                 WHERE id = ?'
            );
            $stmt->execute([
                $intentoId,
                $currentIndex,
                json_encode($respuestas, JSON_UNESCAPED_UNICODE),
                json_encode($intentos, JSON_UNESCAPED_UNICODE),
                $completada ? 1 : 0,
                $completada ? 1 : 0,
                (int) $row['id'],
            ]);

            $stmt = $pdo->prepare(
                "UPDATE intentos
                 SET estado = ?,
                     correctas = ?,
                     cantidad_respuestas = ?,
                     ultimo_acceso_en = NOW(),
                     finalizado_en = IF(? = 'finalizado', NOW(), finalizado_en),
                     duracion_segundos = ?
                 WHERE id = ? AND alumno_id = ? AND actividad_id = ?"
            );
            $stmt->execute([
                $completada ? 'finalizado' : 'en_progreso',
                $this->contarCorrectas($respuestas, $tasks),
                array_sum(array_map('intval', $intentos)),
                $completada ? 'finalizado' : 'en_progreso',
                max(0, (int) ($payload['elapsedSeconds'] ?? 0)),
                $intentoId,
                $alumnoId,
                $actividadId,
            ]);

            $pdo->commit();

            $data = $this->obtener($actividadId, $alumnoId);
            $data['correct'] = $correcta;
            $data['message'] = $mensaje;

            return $data;
        } catch (Throwable $exception) {
            $pdo->rollBack();
            throw $exception;
        }
    }

    public function tipoActividad(int $actividadId): bool
    {
        $stmt = db()->prepare(
            "SELECT COUNT(*)
             FROM actividades a
             INNER JOIN contenedores_actividad ca ON ca.id = a.contenedor_id
             INNER JOIN temas t ON t.id = ca.tema_id
             WHERE a.id = ? AND t.nombre = 'Matemática' AND a.titulo = ?"
        );
        $stmt->execute([$actividadId, self::TITLE]);

        return (int) $stmt->fetchColumn() === 1;
    }

    private function mapear(array $row): array
    {
        $a = (int) $row['indice_a'];
        $b = (int) $row['indice_b'];
        $tasks = $this->tasks($a, $b);
        $respuestas = $this->json((string) $row['respuestas_json']);
        $intentos = $this->json((string) $row['intentos_json']);
        $currentIndex = min((int) $row['tarea_actual'], count($tasks));
        $currentTask = $tasks[$currentIndex] ?? ['type' => 'completed', 'id' => 'completed'];
        $routes = $this->routesForClient($a, $b, $tasks, $respuestas);

        return [
            'title' => self::TITLE,
            'activityType' => self::ACTIVITY_TYPE,
            'version' => ['a' => $a, 'b' => $b],
            'currentTaskIndex' => $currentIndex,
            'totalTasks' => count($tasks),
            'totalCalculations' => count(array_filter($tasks, fn (array $task): bool => $task['type'] === 'calc')),
            'correctCalculations' => $this->contarCalculos($respuestas, $tasks),
            'attempts' => array_sum(array_map('intval', $intentos)),
            'completed' => (int) $row['completada'] === 1,
            'currentTask' => $this->taskForClient($currentTask),
            'routes' => $routes,
            'conclusions' => $this->conclusions($respuestas),
        ];
    }

    private function tasks(int $aIndex, int $bIndex): array
    {
        $routes = $this->routeDefinitions($aIndex, $bIndex);
        $tasks = [];
        foreach ($routes as $route) {
            foreach ($route['calculations'] as $index => $calc) {
                $tasks[] = [
                    ...$calc,
                    'id' => $route['key'] . '_calc_' . $index,
                    'routeKey' => $route['key'],
                    'routeTitle' => $route['title'],
                    'type' => 'calc',
                ];
            }
            foreach ($route['questions'] as $index => $question) {
                $tasks[] = [
                    ...$question,
                    'id' => $route['key'] . '_choice_' . $index,
                    'routeKey' => $route['key'],
                    'routeTitle' => $route['title'],
                    'type' => 'choice',
                ];
            }
        }

        $tasks[] = [
            'id' => 'closing_choice',
            'type' => 'closing',
            'routeKey' => 'closing',
            'routeTitle' => 'Cierre comparativo',
            'prompt' => '¿Cuál es la principal diferencia entre los modelos estudiados?',
            'options' => [
                'Todos los modelos crecen sin límite cuando la variable aumenta.',
                'La fuerza y el campo crecen sin límite cuando la distancia se acerca a cero. La resistencia equivalente y la población crecen hacia un valor límite cuando su variable independiente aumenta.',
                'La resistencia y la población tienden a cero, mientras que fuerza y campo son constantes.',
                'Los cuatro modelos tienen exactamente la misma asíntota vertical.',
            ],
            'correct' => 1,
            'conclusion' => 'La fuerza y el campo crecen sin límite cuando la distancia se acerca a cero. La resistencia equivalente y la población crecen hacia un valor límite cuando su variable independiente aumenta.',
        ];

        return $tasks;
    }

    private function routeDefinitions(int $aIndex, int $bIndex): array
    {
        $i = $aIndex - 1;
        $j = $bIndex - 1;
        $f0 = [3.2, 3.4, 3.6, 3.8, 4.0, 4.2, 4.4, 4.6][$i];
        $r0 = [0.40, 0.42, 0.44, 0.46, 0.48, 0.50, 0.52, 0.54][$j];
        $q = [0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5][$i];
        $rf = [8, 9, 10, 11, 12, 13, 14, 15][$i];
        $x0 = [1, 2, 3, 4, 5, 6, 7, 8][$j];
        $pmax = [2800, 2900, 3000, 3100, 3200, 3300, 3400, 3500][$i];
        $c = [1.0, 1.2, 1.4, 1.6, 1.8, 2.0, 2.2, 2.4][$j];

        return [
            [
                'key' => 'coulomb',
                'title' => 'Ley de Coulomb',
                'intro' => 'La fuerza depende de la distancia r. Como las cargas son las mismas, usamos el dato conocido F(r0)=F0 para calcular otros valores.',
                'formula' => 'F(r)=F0·(r0/r)^2. Dato conocido: F(r0)=F0.',
                'xLabel' => 'r (m)',
                'yLabel' => 'F (µN)',
                'unit' => 'µN',
                'knownRows' => [['x' => $r0, 'y' => $f0, 'label' => 'r0']],
                'parameters' => [['label' => 'F0 conocida', 'value' => $this->fmt($f0) . ' µN'], ['label' => 'r0 conocida', 'value' => $this->fmt($r0) . ' m']],
                'calculations' => array_map(fn (array $item): array => [
                    'prompt' => 'Completá F(' . $item['name'] . ') = ?. Usá la ecuación F(r)=F0·(r0/r)^2 y reemplazá r por ' . $item['name'] . ' = ' . $this->fmt($item['r']) . ' m. Datos: F0 = ' . $this->fmt($f0) . ' µN y r0 = ' . $this->fmt($r0) . ' m.',
                    'x' => $item['r'],
                    'answer' => $f0 * (($r0 / $item['r']) ** 2),
                    'unit' => 'µN',
                    'toleranceType' => 'relative',
                    'tolerance' => 0.01,
                    'xLabel' => $item['name'] . ' = ' . $this->fmt($item['r']) . ' m',
                ], [
                    ['name' => 'r1', 'r' => $r0 / 2],
                    ['name' => 'r2', 'r' => $r0 / 5],
                    ['name' => 'r3', 'r' => $r0 / 10],
                    ['name' => 'r4', 'label' => 'r4', 'r' => 0.0005],
                ]),
                'questions' => [
                    [
                        'prompt' => '¿Qué sucede con la fuerza cuando la distancia se aproxima a cero?',
                        'options' => ['La fuerza se aproxima a cero.', 'La fuerza permanece constante.', 'La fuerza aumenta sin límite y matemáticamente tiende a infinito.', 'La fuerza se vuelve necesariamente negativa.'],
                        'correct' => 2,
                    ],
                    [
                        'prompt' => '¿Por qué no puede utilizarse r = 0 en la fórmula?',
                        'options' => ['Porque se produciría una división por cero.', 'Porque la fuerza siempre sería cero.', 'Porque las cargas desaparecerían.', 'Porque cambiaría el valor de la constante.'],
                        'correct' => 0,
                        'conclusion' => 'Matemáticamente, r = 0 no pertenece al dominio y constituye una asíntota vertical. Cuando r tiende a 0 por derecha, la fuerza tiende a infinito positivo.',
                    ],
                ],
            ],
            [
                'key' => 'campo',
                'title' => 'Campo eléctrico',
                'intro' => 'Ahora investigaremos el campo eléctrico producido por una carga puntual y compararemos su comportamiento con la fuerza eléctrica.',
                'formula' => 'E(r)=k·|Q|/r^2, con k = 9×10^9 N m^2/C^2.',
                'xLabel' => 'r (m)',
                'yLabel' => 'E (N/C)',
                'unit' => 'N/C',
                'knownRows' => [],
                'parameters' => [['label' => 'Q', 'value' => $this->fmt($q) . ' nC'], ['label' => 'k', 'value' => '9×10^9 N m^2/C^2'], ['label' => 'r0', 'value' => $this->fmt($r0) . ' m']],
                'calculations' => array_map(fn (array $item): array => [
                    'prompt' => 'Completá E(' . $item['name'] . ') = ?. En la ecuación E(r), reemplazá r por ' . $item['name'] . ' = ' . $this->fmt($item['r']) . ' m. Usá Q = ' . $this->fmt($q) . ' nC.',
                    'x' => $item['r'],
                    'answer' => self::K * ($q * 1e-9) / ($item['r'] ** 2),
                    'unit' => 'N/C',
                    'toleranceType' => 'relative',
                    'tolerance' => 0.01,
                    'xLabel' => $item['name'] . ' = ' . $this->fmt($item['r']) . ' m',
                ], [
                    ['name' => 'r0', 'r' => $r0],
                    ['name' => 'r1', 'r' => $r0 / 2],
                    ['name' => 'r2', 'r' => $r0 / 5],
                    ['name' => 'r3', 'r' => $r0 / 10],
                    ['name' => 'r4', 'r' => 0.0005],
                ]),
                'questions' => [
                    [
                        'prompt' => '¿Qué interpretación describe correctamente el comportamiento del campo eléctrico?',
                        'options' => ['Disminuye cuando nos acercamos a la carga.', 'Permanece constante para cualquier distancia.', 'Aumenta al acercarnos a la carga y tiende a infinito cuando r tiende a 0 por derecha.', 'Se vuelve igual a cero cuando la distancia es muy pequeña.'],
                        'correct' => 2,
                    ],
                    [
                        'prompt' => '¿Por qué la fuerza de Coulomb y el campo eléctrico presentan gráficos semejantes?',
                        'options' => ['Porque ambos dependen inversamente del cuadrado de la distancia.', 'Porque ambos tienen siempre el mismo valor.', 'Porque no dependen de la distancia.', 'Porque sus unidades son iguales.'],
                        'correct' => 0,
                        'conclusion' => 'La fuerza de Coulomb y el campo eléctrico comparten una dependencia inversa cuadrática con la distancia.',
                    ],
                ],
            ],
            [
                'key' => 'resistencia',
                'title' => 'Resistencia equivalente',
                'intro' => 'Un resistor fijo está conectado en paralelo con un resistor variable. Analizaremos cómo cambia la resistencia equivalente cuando aumenta el resistor variable.',
                'formula' => 'R(x)=Rf·x/(Rf+x). Rf es la resistencia fija.',
                'xLabel' => 'x (Ω)',
                'yLabel' => 'R (Ω)',
                'unit' => 'Ω',
                'asymptote' => $rf,
                'knownRows' => [],
                'parameters' => [['label' => 'Rf fija', 'value' => $rf . ' Ω'], ['label' => 'x0 inicial', 'value' => $x0 . ' Ω']],
                'calculations' => array_map(fn (array $item): array => [
                    'prompt' => 'Completá R(' . $item['name'] . ') = ?. Usá la ecuación R(x)=Rf·x/(Rf+x) y reemplazá x por ' . $item['name'] . ' = ' . $this->fmt($item['x']) . ' Ω. Dato: Rf = ' . $rf . ' Ω.',
                    'x' => $item['x'],
                    'answer' => ($rf * $item['x']) / ($rf + $item['x']),
                    'unit' => 'Ω',
                    'toleranceType' => 'absolute',
                    'tolerance' => 0.02,
                    'xLabel' => $item['name'] . ' = ' . $this->fmt($item['x']) . ' Ω',
                ], [
                    ['name' => 'x1', 'x' => $x0],
                    ['name' => 'x2', 'x' => 5 * $x0],
                    ['name' => 'x3', 'x' => 20 * $x0],
                    ['name' => 'x4', 'x' => 100 * $x0],
                    ['name' => 'x5', 'x' => 1000 * $x0],
                ]),
                'questions' => [[
                    'prompt' => '¿Qué sucede con la resistencia equivalente cuando x aumenta?',
                    'options' => ['Aumenta sin límite.', 'Se aproxima a Rf desde valores menores.', 'Se aproxima a cero.', 'Siempre supera a Rf.'],
                    'correct' => 1,
                    'conclusion' => 'La resistencia equivalente aumenta, pero no supera a la resistencia fija. Matemáticamente, Rf es la asíntota horizontal del modelo.',
                ]],
            ],
            [
                'key' => 'poblacion',
                'title' => 'Crecimiento poblacional',
                'intro' => 'Una población crece rápidamente durante los primeros meses, pero los recursos disponibles impiden un crecimiento ilimitado.',
                'formula' => 'P(t)=Pmax·t/(t+c). Pmax es el valor límite.',
                'xLabel' => 't (meses)',
                'yLabel' => 'P (individuos)',
                'unit' => 'individuos',
                'asymptote' => $pmax,
                'knownRows' => [],
                'parameters' => [['label' => 'Pmax límite', 'value' => (string) $pmax], ['label' => 'c', 'value' => $this->fmt($c) . ' meses']],
                'calculations' => array_map(fn (array $item): array => [
                    'prompt' => 'Completá P(' . $item['name'] . ') = ?. Usá la ecuación P(t)=Pmax·t/(t+c) y reemplazá t por ' . $item['name'] . ' = ' . $this->fmt($item['t']) . ' meses. Datos: Pmax = ' . $pmax . ' y c = ' . $this->fmt($c) . ' meses.',
                    'x' => $item['t'],
                    'answer' => round(($pmax * $item['t']) / ($item['t'] + $c)),
                    'unit' => 'individuos',
                    'toleranceType' => 'absolute',
                    'tolerance' => 1.0,
                    'xLabel' => $item['name'] . ' = ' . $this->fmt($item['t']) . ' meses',
                ], [
                    ['name' => 't0', 't' => 0.0],
                    ['name' => 't1', 't' => 1.0],
                    ['name' => 't2', 't' => 5.0],
                    ['name' => 't3', 't' => 20.0],
                    ['name' => 't4', 't' => 100.0],
                    ['name' => 't5', 't' => 1000.0],
                ]),
                'questions' => [[
                    'prompt' => '¿Qué sucede con la población a medida que transcurre mucho tiempo?',
                    'options' => ['Disminuye necesariamente hasta cero.', 'Aumenta sin límite.', 'Se aproxima progresivamente a Pmax.', 'Permanece igual a la población del primer mes.'],
                    'correct' => 2,
                    'conclusion' => 'Pmax representa el valor límite del modelo. La población se aproxima a ese valor, aunque la fórmula no lo alcanza exactamente para un tiempo finito.',
                ]],
            ],
        ];
    }

    private function routesForClient(int $a, int $b, array $tasks, array $respuestas): array
    {
        return array_map(function (array $route) use ($tasks, $respuestas): array {
            $rows = $route['knownRows'];
            foreach ($tasks as $task) {
                if (($task['routeKey'] ?? '') === $route['key'] && $task['type'] === 'calc' && isset($respuestas[$task['id']])) {
                    $rows[] = [
                        'x' => (float) $task['x'],
                        'y' => (float) $task['answer'],
                        'label' => (string) ($task['xLabel'] ?? ''),
                    ];
                }
            }

            return [
                'key' => $route['key'],
                'title' => $route['title'],
                'intro' => $route['intro'],
                'formula' => $route['formula'],
                'xLabel' => $route['xLabel'],
                'yLabel' => $route['yLabel'],
                'unit' => $route['unit'],
                'parameters' => $route['parameters'],
                'rows' => $rows,
                'asymptote' => $route['asymptote'] ?? null,
            ];
        }, $this->routeDefinitions($a, $b));
    }

    private function taskForClient(array $task): array
    {
        if (($task['type'] ?? '') === 'calc') {
            return [
                'id' => $task['id'],
                'type' => 'calc',
                'routeKey' => $task['routeKey'],
                'routeTitle' => $task['routeTitle'],
                'prompt' => $task['prompt'],
                'unit' => $task['unit'],
                'xLabel' => $task['xLabel'],
            ];
        }

        if (($task['type'] ?? '') === 'choice' || ($task['type'] ?? '') === 'closing') {
            return [
                'id' => $task['id'],
                'type' => $task['type'],
                'routeKey' => $task['routeKey'],
                'routeTitle' => $task['routeTitle'],
                'prompt' => $task['prompt'],
                'options' => $task['options'],
            ];
        }

        return ['type' => 'completed', 'id' => 'completed'];
    }

    private function dentroDeTolerancia(float $valor, float $esperado, array $task): bool
    {
        if ((string) $task['toleranceType'] === 'relative') {
            return abs($valor - $esperado) <= max(abs($esperado) * (float) $task['tolerance'], 0.000001);
        }

        return abs($valor - $esperado) <= (float) $task['tolerance'];
    }

    private function parseNumero(string $value): ?float
    {
        $normalized = trim(str_replace(',', '.', $value));
        if (!preg_match('/^[-+]?\d+(?:\.\d+)?(?:e[-+]?\d+)?$/i', $normalized)) {
            return null;
        }

        return (float) $normalized;
    }

    private function contarCorrectas(array $respuestas, array $tasks): int
    {
        $total = 0;
        foreach ($tasks as $task) {
            if (isset($respuestas[$task['id']])) {
                $total++;
            }
        }

        return $total;
    }

    private function contarCalculos(array $respuestas, array $tasks): int
    {
        $total = 0;
        foreach ($tasks as $task) {
            if ($task['type'] === 'calc' && isset($respuestas[$task['id']])) {
                $total++;
            }
        }

        return $total;
    }

    private function conclusions(array $respuestas): array
    {
        $items = [];
        $map = [
            'coulomb_choice_1' => 'r = 0 queda fuera del dominio y aparece una asíntota vertical.',
            'campo_choice_1' => 'Fuerza y campo comparten dependencia inversa cuadrática.',
            'resistencia_choice_0' => 'Rf actúa como asíntota horizontal para la resistencia equivalente.',
            'poblacion_choice_0' => 'Pmax es el límite horizontal del modelo poblacional.',
        ];
        foreach ($map as $id => $text) {
            if (isset($respuestas[$id])) {
                $items[] = $text;
            }
        }

        return $items;
    }

    private function asignarIndicesEquilibrados(int $actividadId): array
    {
        $stmt = db()->prepare(
            'SELECT a.n AS indice_a, b.n AS indice_b
             FROM (
               SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8
             ) a
             CROSS JOIN (
               SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8
             ) b
             LEFT JOIN matematica_racional_progreso mrp
               ON mrp.indice_a = a.n AND mrp.indice_b = b.n AND mrp.actividad_id = ?
             GROUP BY a.n, b.n
             ORDER BY COUNT(mrp.id) ASC, a.n ASC, b.n ASC
             LIMIT 1'
        );
        $stmt->execute([$actividadId]);
        $row = $stmt->fetch();

        return ['a' => (int) $row['indice_a'], 'b' => (int) $row['indice_b']];
    }

    private function asegurarActividad(int $actividadId): void
    {
        if (!$this->tipoActividad($actividadId)) {
            throw new InvalidArgumentException('La actividad de Matemática no está configurada.');
        }
    }

    private function obtenerFila(int $actividadId, int $alumnoId, bool $lock = false): ?array
    {
        $sql = 'SELECT * FROM matematica_racional_progreso WHERE alumno_id = ? AND actividad_id = ? LIMIT 1';
        if ($lock) {
            $sql .= ' FOR UPDATE';
        }
        $stmt = db()->prepare($sql);
        $stmt->execute([$alumnoId, $actividadId]);
        $row = $stmt->fetch();

        return $row ?: null;
    }

    private function json(string $value): array
    {
        $decoded = json_decode($value, true);

        return is_array($decoded) ? $decoded : [];
    }

    private function fmt(float $value): string
    {
        return rtrim(rtrim(number_format($value, 4, ',', ''), '0'), ',');
    }
}
