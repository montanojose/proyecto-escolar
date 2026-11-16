<?php

declare(strict_types=1);

require_once dirname(__DIR__) . '/config/database.php';

final class LenguaActividadService
{
    private const STEPS = ['sujeto', 'predicado', 'nucleo_sujeto', 'verbo'];

    private const PROMPTS = [
        'sujeto' => 'Seleccioná todas las palabras que forman el sujeto.',
        'predicado' => 'Seleccioná todas las palabras que forman el predicado.',
        'nucleo_sujeto' => 'Seleccioná la palabra principal del sujeto.',
        'verbo' => 'Seleccioná el verbo de la oración.',
    ];

    private const SUCCESS = [
        'sujeto' => 'Muy bien. Encontraste el sujeto.',
        'predicado' => 'Excelente. Reconociste el predicado.',
        'nucleo_sujeto' => 'Correcto. Ese es el núcleo del sujeto.',
        'verbo' => 'Muy bien. Ese es el verbo y núcleo del predicado.',
    ];

    private const HINTS = [
        'sujeto' => 'Revisá qué persona, animal, objeto o elemento realiza la acción.',
        'predicado' => 'Buscá qué se dice acerca del sujeto.',
        'nucleo_sujeto' => 'Buscá la palabra principal del sujeto.',
        'verbo' => 'Buscá la palabra que expresa la acción.',
    ];

    public function iniciar(int $actividadId, int $alumnoId, int $intentoId): array
    {
        $this->asegurarActividad($actividadId);
        $pdo = db();
        $pdo->beginTransaction();

        try {
            $stmt = $pdo->prepare(
                'SELECT id, completada, oracion_id
                 FROM lengua_progreso
                 WHERE alumno_id = ? AND actividad_id = ?
                 LIMIT 1
                 FOR UPDATE'
            );
            $stmt->execute([$alumnoId, $actividadId]);
            $progreso = $stmt->fetch();
            $progresoId = $progreso['id'] ?? null;

            if (!$progresoId) {
                $oracionId = $this->asignarOracionEquilibrada($actividadId, $alumnoId);
                $stmt = $pdo->prepare(
                    'INSERT INTO lengua_progreso (alumno_id, actividad_id, intento_id, oracion_id, paso_actual, respuestas_json, intentos_json, iniciado_en, ultimo_acceso_en)
                     VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW())'
                );
                $stmt->execute([$alumnoId, $actividadId, $intentoId, $oracionId, 'sujeto', '{}', '{}']);
                $this->registrarAsignacion($alumnoId, $actividadId, $intentoId, $oracionId);
            } elseif ((int) ($progreso['completada'] ?? 0) === 1) {
                $oracionId = $this->asignarOracionEquilibrada($actividadId, $alumnoId, (int) $progreso['oracion_id']);
                $stmt = $pdo->prepare(
                    "UPDATE lengua_progreso
                     SET intento_id = ?, oracion_id = ?, paso_actual = 'sujeto',
                         respuestas_json = '{}', intentos_json = '{}', completada = 0,
                         iniciado_en = NOW(), ultimo_acceso_en = NOW(), finalizado_en = NULL
                     WHERE id = ?"
                );
                $stmt->execute([$intentoId, $oracionId, (int) $progresoId]);
                $this->registrarAsignacion($alumnoId, $actividadId, $intentoId, $oracionId);
            } else {
                $stmt = $pdo->prepare(
                    'UPDATE lengua_progreso
                     SET intento_id = ?, ultimo_acceso_en = NOW()
                     WHERE id = ? AND completada = 0'
                );
                $stmt->execute([$intentoId, (int) $progresoId]);
                $this->registrarAsignacion($alumnoId, $actividadId, $intentoId, (int) $progreso['oracion_id']);
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
        $stmt = db()->prepare(
            'SELECT lp.*, lo.texto, lo.palabras_json
             FROM lengua_progreso lp
             INNER JOIN lengua_oraciones lo ON lo.id = lp.oracion_id
             WHERE lp.alumno_id = ? AND lp.actividad_id = ?
             LIMIT 1'
        );
        $stmt->execute([$alumnoId, $actividadId]);
        $row = $stmt->fetch();

        if (!$row) {
            throw new InvalidArgumentException('Primero hay que iniciar la actividad.');
        }

        return $this->mapearProgreso($row);
    }

    public function verificar(int $actividadId, int $alumnoId, int $intentoId, string $paso, array $seleccion, int $duracionSegundos = 0): array
    {
        if (!in_array($paso, self::STEPS, true)) {
            throw new InvalidArgumentException('El paso indicado no existe.');
        }

        $pdo = db();
        $pdo->beginTransaction();

        try {
            $stmt = $pdo->prepare(
                'SELECT lp.*, lo.respuesta_json
                 FROM lengua_progreso lp
                 INNER JOIN lengua_oraciones lo ON lo.id = lp.oracion_id
                 WHERE lp.alumno_id = ? AND lp.actividad_id = ?
                 LIMIT 1
                 FOR UPDATE'
            );
            $stmt->execute([$alumnoId, $actividadId]);
            $row = $stmt->fetch();

            if (!$row) {
                throw new InvalidArgumentException('No encontramos el avance de esta actividad.');
            }

            if ((int) $row['completada'] === 1) {
                $pdo->commit();
                return array_merge($this->obtener($actividadId, $alumnoId), [
                    'correct' => true,
                    'message' => 'Actividad completada.',
                ]);
            }

            if ((string) $row['paso_actual'] !== $paso) {
                throw new InvalidArgumentException('Ese paso todavía no está habilitado.');
            }

            $respuestas = $this->decodificarJson((string) $row['respuestas_json']);
            $intentos = $this->decodificarJson((string) $row['intentos_json']);
            $respuestaCorrecta = $this->decodificarJson((string) $row['respuesta_json']);
            $seleccionNormalizada = $this->normalizarSeleccion($seleccion);
            $esperada = $this->normalizarSeleccion($respuestaCorrecta[$paso] ?? []);
            $correcta = $seleccionNormalizada === $esperada;

            $respuestas[$paso] = $seleccionNormalizada;
            $intentos[$paso] = ((int) ($intentos[$paso] ?? 0)) + 1;

            $siguientePaso = $paso;
            $completada = false;
            if ($correcta) {
                $posicion = array_search($paso, self::STEPS, true);
                $completada = $posicion === count(self::STEPS) - 1;
                $siguientePaso = $completada ? 'completada' : self::STEPS[$posicion + 1];
            }

            $stmt = $pdo->prepare(
                'UPDATE lengua_progreso
                 SET intento_id = ?, paso_actual = ?, respuestas_json = ?, intentos_json = ?,
                     completada = ?, finalizado_en = IF(? = 1, NOW(), finalizado_en), ultimo_acceso_en = NOW()
                 WHERE id = ?'
            );
            $stmt->execute([
                $intentoId,
                $siguientePaso,
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
                $this->contarCorrectas($respuestas, $respuestaCorrecta),
                array_sum(array_map('intval', $intentos)),
                $completada ? 'finalizado' : 'en_progreso',
                max(0, $duracionSegundos),
                $intentoId,
                $alumnoId,
                $actividadId,
            ]);

            $pdo->commit();

            $data = $this->obtener($actividadId, $alumnoId);
            $data['correct'] = $correcta;
            $data['message'] = $correcta ? self::SUCCESS[$paso] : self::HINTS[$paso];

            return $data;
        } catch (Throwable $exception) {
            $pdo->rollBack();
            throw $exception;
        }
    }

    public function analisisFinal(int $actividadId, int $alumnoId): array
    {
        $stmt = db()->prepare(
            'SELECT lo.palabras_json, lo.respuesta_json
             FROM lengua_progreso lp
             INNER JOIN lengua_oraciones lo ON lo.id = lp.oracion_id
             WHERE lp.alumno_id = ? AND lp.actividad_id = ? AND lp.completada = 1
             LIMIT 1'
        );
        $stmt->execute([$alumnoId, $actividadId]);
        $row = $stmt->fetch();

        if (!$row) {
            return [];
        }

        return [
            'words' => $this->decodificarJson((string) $row['palabras_json']),
            'answer' => $this->decodificarJson((string) $row['respuesta_json']),
        ];
    }

    private function asegurarActividad(int $actividadId): void
    {
        $stmt = db()->prepare(
            "SELECT COUNT(*)
             FROM actividades a
             INNER JOIN contenedores_actividad ca ON ca.id = a.contenedor_id
             INNER JOIN temas t ON t.id = ca.tema_id
             WHERE a.id = ? AND t.nombre = 'Lengua' AND a.titulo = 'Reconocemos el sujeto y el predicado'"
        );
        $stmt->execute([$actividadId]);

        if ((int) $stmt->fetchColumn() !== 1) {
            throw new InvalidArgumentException('La actividad de Lengua no está configurada.');
        }
    }

    private function asignarOracionEquilibrada(int $actividadId, int $alumnoId, ?int $excluirOracionId = null): int
    {
        $soloNuevas = $this->hayOracionesSinUsar($actividadId, $alumnoId, $excluirOracionId);
        $stmt = db()->prepare(
            'SELECT lo.id
             FROM lengua_oraciones lo
             LEFT JOIN lengua_asignaciones la ON la.oracion_id = lo.id AND la.actividad_id = ?
             WHERE lo.activa = 1
               AND (? IS NULL OR lo.id <> ?)
               AND (
                 ? = 0 OR NOT EXISTS (
                   SELECT 1
                   FROM lengua_asignaciones alumno_la
                   WHERE alumno_la.actividad_id = ?
                     AND alumno_la.alumno_id = ?
                     AND alumno_la.oracion_id = lo.id
                 )
               )
             GROUP BY lo.id
             ORDER BY COUNT(la.id) ASC, lo.id ASC
             LIMIT 1'
        );
        $stmt->execute([
            $actividadId,
            $excluirOracionId,
            $excluirOracionId,
            $soloNuevas ? 1 : 0,
            $actividadId,
            $alumnoId,
        ]);
        $oracionId = $stmt->fetchColumn();

        if (!$oracionId && $excluirOracionId !== null) {
            return $this->asignarOracionEquilibrada($actividadId, $alumnoId, null);
        }

        if (!$oracionId) {
            throw new InvalidArgumentException('No hay oraciones cargadas para la actividad.');
        }

        return (int) $oracionId;
    }

    private function hayOracionesSinUsar(int $actividadId, int $alumnoId, ?int $excluirOracionId = null): bool
    {
        $stmt = db()->prepare(
            'SELECT COUNT(*)
             FROM lengua_oraciones lo
             WHERE lo.activa = 1
               AND (? IS NULL OR lo.id <> ?)
               AND NOT EXISTS (
                 SELECT 1
                 FROM lengua_asignaciones la
                 WHERE la.actividad_id = ?
                   AND la.alumno_id = ?
                   AND la.oracion_id = lo.id
               )'
        );
        $stmt->execute([$excluirOracionId, $excluirOracionId, $actividadId, $alumnoId]);

        return (int) $stmt->fetchColumn() > 0;
    }

    private function registrarAsignacion(int $alumnoId, int $actividadId, int $intentoId, int $oracionId): void
    {
        if ($intentoId <= 0 || $oracionId <= 0) {
            return;
        }

        $stmt = db()->prepare(
            'INSERT INTO lengua_asignaciones (alumno_id, actividad_id, intento_id, oracion_id, asignado_en)
             VALUES (?, ?, ?, ?, NOW())
             ON DUPLICATE KEY UPDATE
               alumno_id = VALUES(alumno_id),
               actividad_id = VALUES(actividad_id),
               oracion_id = VALUES(oracion_id)'
        );
        $stmt->execute([$alumnoId, $actividadId, $intentoId, $oracionId]);
    }

    private function mapearProgreso(array $row): array
    {
        $paso = (string) $row['paso_actual'];
        $completada = (int) $row['completada'] === 1;
        $respuestas = $this->decodificarJson((string) $row['respuestas_json']);
        $intentos = $this->decodificarJson((string) $row['intentos_json']);

        return [
            'title' => 'Reconocemos el sujeto y el predicado',
            'intro' => 'Leé atentamente la oración. Después seleccioná las palabras que forman el sujeto, el predicado y sus núcleos.',
            'sentenceId' => (int) $row['oracion_id'],
            'sentence' => (string) $row['texto'],
            'words' => $this->decodificarJson((string) $row['palabras_json']),
            'currentStep' => $paso,
            'currentStepIndex' => $completada ? 4 : max(0, array_search($paso, self::STEPS, true)),
            'steps' => array_map(fn (string $item): array => [
                'key' => $item,
                'prompt' => self::PROMPTS[$item],
                'attempts' => (int) ($intentos[$item] ?? 0),
                'selection' => array_values(array_map('intval', $respuestas[$item] ?? [])),
            ], self::STEPS),
            'completed' => $completada,
            'analysis' => $completada ? $this->analisisFinal((int) $row['actividad_id'], (int) $row['alumno_id']) : null,
        ];
    }

    private function normalizarSeleccion(array $seleccion): array
    {
        $indices = array_values(array_unique(array_map('intval', $seleccion)));
        sort($indices, SORT_NUMERIC);

        return $indices;
    }

    private function contarCorrectas(array $respuestas, array $correctas): int
    {
        $total = 0;
        foreach (self::STEPS as $paso) {
            if ($this->normalizarSeleccion($respuestas[$paso] ?? []) === $this->normalizarSeleccion($correctas[$paso] ?? [])) {
                $total++;
            }
        }

        return $total;
    }

    private function decodificarJson(string $json): array
    {
        $data = json_decode($json, true);

        return is_array($data) ? $data : [];
    }
}
