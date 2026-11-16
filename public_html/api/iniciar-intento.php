<?php

declare(strict_types=1);

require_once dirname(__DIR__, 2) . '/app_private/config/database.php';
require_once dirname(__DIR__, 2) . '/app_private/services/BancoValoresService.php';
require_once dirname(__DIR__, 2) . '/app_private/services/LenguaActividadService.php';
require_once dirname(__DIR__, 2) . '/app_private/services/MatematicaRacionalService.php';

require_post();

try {
    $body = read_json_body();
    $alumnoId = (int) ($body['studentId'] ?? $body['alumno_id'] ?? 0);
    $actividadId = (int) ($body['activityId'] ?? $body['actividad_id'] ?? 0);
    $actividadClaseId = (int) ($body['classActivityId'] ?? $body['actividad_clase_id'] ?? 0);
    $esInvitado = (bool) ($body['guest'] ?? $body['invitado'] ?? false);

    if ($alumnoId <= 0 || $actividadId <= 0) {
        json_response(['ok' => false, 'message' => 'Faltan datos para iniciar el intento.'], 422);
    }

    if ($actividadClaseId > 0 && !$esInvitado) {
        $stmt = db()->prepare(
            "SELECT ac.id AS actividad_clase_id, ac.clase_id, ac.acceso_habilitado, ac.puntaje_habilitado,
                    CASE
                      WHEN t.nombre = 'Lengua' AND a.titulo = 'Reconocemos el sujeto y el predicado'
                      THEN 'lengua_sujeto_predicado'
                      WHEN t.nombre = 'MatemÃ¡tica' AND a.titulo = 'Aplicaciones de la funciÃ³n racional: calcular, observar e interpretar'
                      THEN 'matematica_funcion_racional'
                      ELSE 'ejercicios'
                    END AS tipo_actividad
             FROM actividades_clase ac
             INNER JOIN actividades a ON a.id = ac.actividad_id
             INNER JOIN contenedores_actividad ca ON ca.id = a.contenedor_id
             INNER JOIN temas t ON t.id = ca.tema_id
             INNER JOIN inscripciones_clase ic ON ic.clase_id = ac.clase_id AND ic.alumno_id = ? AND ic.estado = 'validada'
             WHERE ac.id = ? AND ac.actividad_id = ? AND ac.visible_alumno = 1
               AND (ac.fecha_inicio IS NULL OR ac.fecha_inicio <= NOW())
               AND (ac.fecha_cierre IS NULL OR ac.fecha_cierre >= NOW())
             LIMIT 1"
        );
        $stmt->execute([$alumnoId, $actividadClaseId, $actividadId]);
    } else {
        $stmt = db()->prepare(
        "SELECT a.acceso_habilitado, a.puntaje_habilitado,
                NULL AS actividad_clase_id, NULL AS clase_id,
                CASE
                  WHEN t.nombre = 'Lengua' AND a.titulo = 'Reconocemos el sujeto y el predicado'
                  THEN 'lengua_sujeto_predicado'
                  WHEN t.nombre = 'Matemática' AND a.titulo = 'Aplicaciones de la función racional: calcular, observar e interpretar'
                  THEN 'matematica_funcion_racional'
                  ELSE 'ejercicios'
                END AS tipo_actividad
         FROM actividades a
         INNER JOIN contenedores_actividad ca ON ca.id = a.contenedor_id
         INNER JOIN temas t ON t.id = ca.tema_id
         WHERE a.id = ? LIMIT 1"
        );
        $stmt->execute([$actividadId]);
    }
    $actividad = $stmt->fetch();

    if (!$actividad) {
        json_response(['ok' => false, 'message' => 'La actividad no existe.'], 404);
    }

    if ((int) $actividad['acceso_habilitado'] !== 1) {
        json_response(['ok' => false, 'message' => 'El profesor todavía no habilitó el ingreso a esta actividad.'], 403);
    }

    $modo = !$esInvitado && ((int) $actividad['puntaje_habilitado'] === 1) ? 'evaluativo' : 'practica';
    $tipoActividad = (string) ($actividad['tipo_actividad'] ?? 'ejercicios');

    if ($tipoActividad === 'lengua_sujeto_predicado') {
        $stmt = db()->prepare(
            "SELECT id
             FROM intentos
             WHERE alumno_id = ? AND actividad_id = ? AND COALESCE(actividad_clase_id, 0) = ? AND estado <> 'finalizado'
             ORDER BY id DESC
             LIMIT 1"
        );
        $stmt->execute([$alumnoId, $actividadId, $actividadClaseId]);
        $intentoId = (int) ($stmt->fetchColumn() ?: 0);

        if ($intentoId <= 0) {
            $stmt = db()->prepare(
                "INSERT INTO intentos (alumno_id, actividad_id, actividad_clase_id, clase_id, modo, estado, iniciado_en, ultimo_acceso_en)
                 VALUES (?, ?, ?, ?, ?, 'iniciado', NOW(), NOW())"
            );
            $stmt->execute([$alumnoId, $actividadId, $actividadClaseId ?: null, $actividad['clase_id'] ?? null, $modo]);
            $intentoId = (int) db()->lastInsertId();
        }

        $lengua = (new LenguaActividadService())->iniciar($actividadId, $alumnoId, $intentoId);

        json_response([
            'ok' => true,
            'data' => [
                'attemptId' => $intentoId,
                'mode' => $modo,
                'pointsEnabled' => $modo === 'evaluativo',
                'guest' => $esInvitado,
                'activityType' => $tipoActividad,
                'languageActivity' => $lengua,
            ],
        ]);
    }

    if ($tipoActividad === 'matematica_funcion_racional') {
        $stmt = db()->prepare(
            "SELECT id
             FROM intentos
             WHERE alumno_id = ? AND actividad_id = ? AND COALESCE(actividad_clase_id, 0) = ? AND estado <> 'finalizado'
             ORDER BY id DESC
             LIMIT 1"
        );
        $stmt->execute([$alumnoId, $actividadId, $actividadClaseId]);
        $intentoId = (int) ($stmt->fetchColumn() ?: 0);

        if ($intentoId <= 0) {
            $stmt = db()->prepare(
                "INSERT INTO intentos (alumno_id, actividad_id, actividad_clase_id, clase_id, modo, estado, iniciado_en, ultimo_acceso_en)
                 VALUES (?, ?, ?, ?, ?, 'iniciado', NOW(), NOW())"
            );
            $stmt->execute([$alumnoId, $actividadId, $actividadClaseId ?: null, $actividad['clase_id'] ?? null, $modo]);
            $intentoId = (int) db()->lastInsertId();
        }

        $math = (new MatematicaRacionalService())->iniciar($actividadId, $alumnoId, $intentoId);

        json_response([
            'ok' => true,
            'data' => [
                'attemptId' => $intentoId,
                'mode' => $modo,
                'pointsEnabled' => $modo === 'evaluativo',
                'guest' => $esInvitado,
                'activityType' => $tipoActividad,
                'mathActivity' => $math,
            ],
        ]);
    }

    $stmt = db()->prepare(
        "INSERT INTO intentos (alumno_id, actividad_id, actividad_clase_id, clase_id, modo, estado, iniciado_en, ultimo_acceso_en)
         VALUES (?, ?, ?, ?, ?, 'iniciado', NOW(), NOW())"
    );
    $stmt->execute([$alumnoId, $actividadId, $actividadClaseId ?: null, $actividad['clase_id'] ?? null, $modo]);
    $intentoId = (int) db()->lastInsertId();

    $stmt = db()->prepare('SELECT id FROM ejercicios WHERE actividad_id = ? AND activo = 1 ORDER BY orden, id');
    $stmt->execute([$actividadId]);
    $bancos = new BancoValoresService();
    foreach ($stmt->fetchAll() as $ejercicio) {
        $bancos->asignarCombinacion($alumnoId, (int) $ejercicio['id'], $intentoId);
    }

    json_response([
        'ok' => true,
        'data' => [
            'attemptId' => $intentoId,
            'mode' => $modo,
            'pointsEnabled' => $modo === 'evaluativo',
            'guest' => $esInvitado,
        ],
    ]);
} catch (Throwable $exception) {
    json_response(['ok' => false, 'message' => 'No se pudo iniciar el intento.'], 500);
}
