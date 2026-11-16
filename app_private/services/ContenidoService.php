<?php

declare(strict_types=1);

require_once dirname(__DIR__) . '/config/database.php';

final class ContenidoService
{
    public function listarCursos(): array
    {
        return db()->query(
            'SELECT c.id, c.materia_id, m.nombre AS materia, c.anio, c.division,
                    c.nombre, c.especialidad, c.turno, c.ciclo_lectivo, c.activo
             FROM cursos c
             LEFT JOIN materias m ON m.id = c.materia_id
             WHERE c.activo = 1
             ORDER BY c.activo DESC, c.ciclo_lectivo DESC, c.anio, c.division, c.nombre'
        )->fetchAll();
    }

    public function guardarCurso(array $data, ?int $id = null): array
    {
        $nombre = input_string($data, 'nombre');
        $cicloLectivo = input_int($data, 'ciclo_lectivo', (int) date('Y'));

        if ($nombre === '') {
            throw new InvalidArgumentException('El curso necesita un nombre.');
        }

        $especialidad = input_string($data, 'especialidad');
        $turno = input_string($data, 'turno');
        $activo = input_bool($data, 'activo', true) ? 1 : 0;
        $pdo = db();

        if ($id) {
            $stmt = $pdo->prepare(
                'UPDATE cursos SET nombre = ?, especialidad = ?, turno = ?, ciclo_lectivo = ?, activo = ? WHERE id = ?'
            );
            $stmt->execute([$nombre, $especialidad, $turno, $cicloLectivo, $activo, $id]);
            return $this->obtenerPorId('cursos', $id);
        }

        $stmt = $pdo->prepare(
            'INSERT INTO cursos (nombre, especialidad, turno, ciclo_lectivo, activo) VALUES (?, ?, ?, ?, ?)'
        );
        $stmt->execute([$nombre, $especialidad, $turno, $cicloLectivo, $activo]);

        return $this->obtenerPorId('cursos', (int) $pdo->lastInsertId());
    }

    public function listarAlumnos(?int $cursoId = null): array
    {
        $sql = "SELECT a.id, a.dni, a.nombre, a.fecha_nacimiento,
                       c.id AS curso_id, c.nombre AS curso, i.activo AS inscripcion_activa
                FROM alumnos a
                LEFT JOIN inscripciones i ON i.alumno_id = a.id AND i.activo = 1
                LEFT JOIN cursos c ON c.id = i.curso_id";
        $params = [];

        if ($cursoId) {
            $sql .= ' WHERE c.id = ?';
            $params[] = $cursoId;
        }

        $sql .= ' ORDER BY a.nombre';
        $stmt = db()->prepare($sql);
        $stmt->execute($params);

        return $stmt->fetchAll();
    }

    public function guardarAlumno(array $data, ?int $id = null): array
    {
        $dni = preg_replace('/\D+/', '', input_string($data, 'dni')) ?? '';
        $nombre = input_string($data, 'nombre');
        $fechaNacimiento = input_string($data, 'fecha_nacimiento') ?: null;
        $cursoId = input_int($data, 'curso_id');

        if (strlen($dni) < 7 || $nombre === '') {
            throw new InvalidArgumentException('El alumno necesita DNI válido y nombre.');
        }

        $pdo = db();
        $pdo->beginTransaction();

        try {
            if ($id) {
                $stmt = $pdo->prepare(
                    'UPDATE alumnos SET dni = ?, nombre = ?, fecha_nacimiento = ? WHERE id = ?'
                );
                $stmt->execute([$dni, $nombre, $fechaNacimiento, $id]);
                $alumnoId = $id;
            } else {
                $stmt = $pdo->prepare(
                    'INSERT INTO alumnos (dni, nombre, fecha_nacimiento)
                     VALUES (?, ?, ?)
                     ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), fecha_nacimiento = VALUES(fecha_nacimiento)'
                );
                $stmt->execute([$dni, $nombre, $fechaNacimiento]);

                $lookup = $pdo->prepare('SELECT id FROM alumnos WHERE dni = ? LIMIT 1');
                $lookup->execute([$dni]);
                $alumnoId = (int) $lookup->fetchColumn();
            }

            if ($cursoId > 0) {
                $stmt = $pdo->prepare(
                    'INSERT INTO inscripciones (alumno_id, curso_id, fecha_alta, activo)
                     VALUES (?, ?, CURRENT_DATE, 1)
                     ON DUPLICATE KEY UPDATE activo = VALUES(activo)'
                );
                $stmt->execute([$alumnoId, $cursoId]);
            }

            $pdo->commit();
            return $this->obtenerAlumno($alumnoId);
        } catch (Throwable $exception) {
            $pdo->rollBack();
            throw $exception;
        }
    }

    public function obtenerAlumno(int $id): array
    {
        $stmt = db()->prepare('SELECT id, dni, nombre, fecha_nacimiento FROM alumnos WHERE id = ? LIMIT 1');
        $stmt->execute([$id]);
        $row = $stmt->fetch();

        if (!$row) {
            throw new InvalidArgumentException('No encontramos ese alumno.');
        }

        return $row;
    }

    public function listarTemas(): array
    {
        return db()->query(
            'SELECT id, nombre, descripcion, orden, activo FROM temas ORDER BY orden, nombre'
        )->fetchAll();
    }

    public function guardarTema(array $data, ?int $id = null): array
    {
        $nombre = input_string($data, 'nombre');
        if ($nombre === '') {
            throw new InvalidArgumentException('El tema necesita un nombre.');
        }

        $descripcion = input_string($data, 'descripcion');
        $orden = input_int($data, 'orden', 100);
        $activo = input_bool($data, 'activo', true) ? 1 : 0;
        $pdo = db();

        if ($id) {
            $stmt = $pdo->prepare(
                'UPDATE temas SET nombre = ?, descripcion = ?, orden = ?, activo = ? WHERE id = ?'
            );
            $stmt->execute([$nombre, $descripcion, $orden, $activo, $id]);
            return $this->obtenerPorId('temas', $id);
        }

        $stmt = $pdo->prepare(
            'INSERT INTO temas (nombre, descripcion, orden, activo) VALUES (?, ?, ?, ?)'
        );
        $stmt->execute([$nombre, $descripcion, $orden, $activo]);

        return $this->obtenerPorId('temas', (int) $pdo->lastInsertId());
    }

    public function listarContenedores(?int $temaId = null): array
    {
        $sql = "SELECT ca.id, ca.tema_id, t.nombre AS tema, ca.nombre, ca.descripcion, ca.orden, ca.activo
                FROM contenedores_actividad ca
                INNER JOIN temas t ON t.id = ca.tema_id";
        $params = [];

        if ($temaId) {
            $sql .= ' WHERE ca.tema_id = ?';
            $params[] = $temaId;
        }

        $sql .= ' ORDER BY t.orden, ca.orden';
        $stmt = db()->prepare($sql);
        $stmt->execute($params);

        return $stmt->fetchAll();
    }

    public function listarTrabajosPracticos(?int $temaId = null): array
    {
        $sql = "SELECT tp.id, tp.tema_id, t.nombre AS tema, tp.titulo, tp.descripcion, tp.codigo, tp.activo,
                       COUNT(st.id) AS secciones
                FROM trabajos_practicos tp
                INNER JOIN temas t ON t.id = tp.tema_id
                LEFT JOIN secciones_tp st ON st.trabajo_practico_id = tp.id";
        $params = [];

        if ($temaId) {
            $sql .= ' WHERE tp.tema_id = ?';
            $params[] = $temaId;
        }

        $sql .= ' GROUP BY tp.id ORDER BY t.orden, tp.id';
        $stmt = db()->prepare($sql);
        $stmt->execute($params);

        return $stmt->fetchAll();
    }

    public function guardarTrabajoPractico(array $data, ?int $id = null): array
    {
        $temaId = input_int($data, 'tema_id');
        $titulo = input_string($data, 'titulo');
        $codigo = input_string($data, 'codigo');

        if ($temaId <= 0 || $titulo === '' || $codigo === '') {
            throw new InvalidArgumentException('El TP necesita tema, título y código.');
        }

        $descripcion = input_string($data, 'descripcion');
        $activo = input_bool($data, 'activo', true) ? 1 : 0;
        $pdo = db();

        if ($id) {
            $stmt = $pdo->prepare(
                'UPDATE trabajos_practicos SET tema_id = ?, titulo = ?, descripcion = ?, codigo = ?, activo = ? WHERE id = ?'
            );
            $stmt->execute([$temaId, $titulo, $descripcion, $codigo, $activo, $id]);
            return $this->obtenerTrabajoPractico($id);
        }

        $stmt = $pdo->prepare(
            'INSERT INTO trabajos_practicos (tema_id, titulo, descripcion, codigo, activo) VALUES (?, ?, ?, ?, ?)'
        );
        $stmt->execute([$temaId, $titulo, $descripcion, $codigo, $activo]);

        return $this->obtenerTrabajoPractico((int) $pdo->lastInsertId());
    }

    public function obtenerTrabajoPractico(int $id): array
    {
        $stmt = db()->prepare(
            'SELECT id, tema_id, titulo, descripcion, codigo, activo FROM trabajos_practicos WHERE id = ? LIMIT 1'
        );
        $stmt->execute([$id]);
        $row = $stmt->fetch();

        if (!$row) {
            throw new InvalidArgumentException('No encontramos ese TP.');
        }

        return $row;
    }

    public function listarSecciones(?int $trabajoPracticoId = null): array
    {
        $sql = "SELECT st.id, st.trabajo_practico_id, tp.titulo AS trabajo_practico,
                       st.titulo, st.descripcion, st.orden, st.activo,
                       COUNT(e.id) AS ejercicios
                FROM secciones_tp st
                INNER JOIN trabajos_practicos tp ON tp.id = st.trabajo_practico_id
                LEFT JOIN ejercicios e ON e.seccion_tp_id = st.id";
        $params = [];

        if ($trabajoPracticoId) {
            $sql .= ' WHERE st.trabajo_practico_id = ?';
            $params[] = $trabajoPracticoId;
        }

        $sql .= ' GROUP BY st.id ORDER BY tp.id, st.orden';
        $stmt = db()->prepare($sql);
        $stmt->execute($params);

        return $stmt->fetchAll();
    }

    public function guardarSeccion(array $data, ?int $id = null): array
    {
        $tpId = input_int($data, 'trabajo_practico_id');
        $titulo = input_string($data, 'titulo');

        if ($tpId <= 0 || $titulo === '') {
            throw new InvalidArgumentException('La sección necesita TP y título.');
        }

        $descripcion = input_string($data, 'descripcion');
        $orden = input_int($data, 'orden', 100);
        $activo = input_bool($data, 'activo', true) ? 1 : 0;
        $pdo = db();

        if ($id) {
            $stmt = $pdo->prepare(
                'UPDATE secciones_tp SET trabajo_practico_id = ?, titulo = ?, descripcion = ?, orden = ?, activo = ? WHERE id = ?'
            );
            $stmt->execute([$tpId, $titulo, $descripcion, $orden, $activo, $id]);
            return $this->obtenerPorId('secciones_tp', $id);
        }

        $stmt = $pdo->prepare(
            'INSERT INTO secciones_tp (trabajo_practico_id, titulo, descripcion, orden, activo) VALUES (?, ?, ?, ?, ?)'
        );
        $stmt->execute([$tpId, $titulo, $descripcion, $orden, $activo]);

        return $this->obtenerPorId('secciones_tp', (int) $pdo->lastInsertId());
    }

    public function listarActividadesAdmin(): array
    {
        return db()->query(
            'SELECT * FROM vista_actividades_publicadas ORDER BY tema, trabajo_practico, seccion, actividad'
        )->fetchAll();
    }

    public function listarEjerciciosAdmin(?int $actividadId = null): array
    {
        $sql = "SELECT
                    e.id,
                    e.actividad_id,
                    a.titulo AS actividad,
                    e.seccion_tp_id,
                    st.titulo AS seccion,
                    e.orden,
                    e.codigo,
                    e.consigna,
                    e.formula_respuesta,
                    e.tolerancia,
                    e.activo,
                    COUNT(DISTINCT ce.id) AS combinaciones
                FROM ejercicios e
                INNER JOIN actividades a ON a.id = e.actividad_id
                LEFT JOIN secciones_tp st ON st.id = e.seccion_tp_id
                LEFT JOIN combinaciones_ejercicio ce ON ce.ejercicio_id = e.id AND ce.activa = 1";
        $params = [];

        if ($actividadId) {
            $sql .= ' WHERE e.actividad_id = ?';
            $params[] = $actividadId;
        }

        $sql .= ' GROUP BY e.id, e.actividad_id, a.titulo, e.seccion_tp_id, st.titulo, e.orden, e.codigo, e.consigna, e.formula_respuesta, e.tolerancia, e.activo
                  ORDER BY a.orden, e.orden, e.id';

        $stmt = db()->prepare($sql);
        $stmt->execute($params);

        return $stmt->fetchAll();
    }

    public function listarBancosValoresAdmin(?int $seccionId = null): array
    {
        $sql = "SELECT
                    b.id,
                    b.seccion_tp_id,
                    st.titulo AS seccion,
                    tp.titulo AS trabajo_practico,
                    m.nombre AS magnitud,
                    m.simbolo AS magnitud_simbolo,
                    u.simbolo AS unidad,
                    b.nombre,
                    b.codigo,
                    b.descripcion,
                    b.orden,
                    b.activo,
                    COUNT(v.id) AS valores
                FROM bancos_valores_seccion b
                INNER JOIN secciones_tp st ON st.id = b.seccion_tp_id
                INNER JOIN trabajos_practicos tp ON tp.id = st.trabajo_practico_id
                INNER JOIN magnitudes m ON m.id = b.magnitud_id
                INNER JOIN unidades u ON u.id = b.unidad_id
                LEFT JOIN valores_banco_seccion v ON v.banco_valores_seccion_id = b.id AND v.activo = 1";
        $params = [];

        if ($seccionId) {
            $sql .= ' WHERE b.seccion_tp_id = ?';
            $params[] = $seccionId;
        }

        $sql .= ' GROUP BY b.id, b.seccion_tp_id, st.titulo, tp.titulo, m.nombre, m.simbolo, u.simbolo, b.nombre, b.codigo, b.descripcion, b.orden, b.activo
                  ORDER BY tp.titulo, st.orden, b.orden, b.id';

        $stmt = db()->prepare($sql);
        $stmt->execute($params);

        return $stmt->fetchAll();
    }

    public function detalleBancoValores(int $bancoId): array
    {
        $stmt = db()->prepare(
            'SELECT id, banco_valores_seccion_id, indice, valor, etiqueta, activo
             FROM valores_banco_seccion
             WHERE banco_valores_seccion_id = ?
             ORDER BY indice'
        );
        $stmt->execute([$bancoId]);

        return $stmt->fetchAll();
    }

    public function guardarActividad(array $data, ?int $id = null): array
    {
        $contenedorId = input_int($data, 'contenedor_id');
        $titulo = input_string($data, 'titulo');
        $descripcion = input_string($data, 'descripcion');

        if ($contenedorId <= 0 || $titulo === '' || $descripcion === '') {
            throw new InvalidArgumentException('La actividad necesita contenedor, título y descripción.');
        }

        $seccionTpId = input_int($data, 'seccion_tp_id') ?: null;
        $nivel = input_string($data, 'nivel', 'Inicial');
        $puntos = input_int($data, 'puntos', 10);
        $estado = input_string($data, 'estado', 'Disponible');
        $visible = input_bool($data, 'visible_alumno', true) ? 1 : 0;
        $acceso = input_bool($data, 'acceso_habilitado', true) ? 1 : 0;
        $puntaje = input_bool($data, 'puntaje_habilitado', true) ? 1 : 0;
        $icono = input_string($data, 'icono', '*');
        $orden = input_int($data, 'orden', 100);
        $pdo = db();

        if ($id) {
            $stmt = $pdo->prepare(
                'UPDATE actividades
                 SET contenedor_id = ?, seccion_tp_id = ?, titulo = ?, descripcion = ?, nivel = ?, puntos = ?,
                     estado = ?, visible_alumno = ?, acceso_habilitado = ?, puntaje_habilitado = ?, icono = ?, orden = ?
                 WHERE id = ?'
            );
            $stmt->execute([
                $contenedorId, $seccionTpId, $titulo, $descripcion, $nivel, $puntos,
                $estado, $visible, $acceso, $puntaje, $icono, $orden, $id,
            ]);
            return $this->obtenerActividadAdmin($id);
        }

        $stmt = $pdo->prepare(
            'INSERT INTO actividades
             (contenedor_id, seccion_tp_id, titulo, descripcion, nivel, puntos, estado,
              visible_alumno, acceso_habilitado, puntaje_habilitado, icono, orden)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'
        );
        $stmt->execute([
            $contenedorId, $seccionTpId, $titulo, $descripcion, $nivel, $puntos,
            $estado, $visible, $acceso, $puntaje, $icono, $orden,
        ]);

        return $this->obtenerActividadAdmin((int) $pdo->lastInsertId());
    }

    public function obtenerActividadAdmin(int $id): array
    {
        $stmt = db()->prepare('SELECT * FROM actividades WHERE id = ? LIMIT 1');
        $stmt->execute([$id]);
        $row = $stmt->fetch();

        if (!$row) {
            throw new InvalidArgumentException('No encontramos esa actividad.');
        }

        return $row;
    }

    public function cambiarEstadoActividad(int $id, array $data): array
    {
        $stmt = db()->prepare(
            'UPDATE actividades
             SET visible_alumno = ?, acceso_habilitado = ?, puntaje_habilitado = ?, estado = ?
             WHERE id = ?'
        );
        $stmt->execute([
            input_bool($data, 'visible_alumno', true) ? 1 : 0,
            input_bool($data, 'acceso_habilitado', false) ? 1 : 0,
            input_bool($data, 'puntaje_habilitado', false) ? 1 : 0,
            input_string($data, 'estado', 'Disponible'),
            $id,
        ]);

        return $this->obtenerActividadAdmin($id);
    }

    public function listarProgreso(?int $cursoId = null, ?int $actividadId = null, ?string $estado = null, bool $soloPendientes = false): array
    {
        $sql = "SELECT
                    i.id AS intento_id,
                    al.id AS alumno_id,
                    al.dni,
                    al.nombre AS alumno,
                    c.id AS curso_id,
                    c.nombre AS curso,
                    a.id AS actividad_id,
                    a.titulo AS actividad,
                    i.modo,
                    i.estado,
                    i.correctas,
                    i.cantidad_respuestas,
                    i.puntaje,
                    i.iniciado_en,
                    i.ultimo_acceso_en,
                    i.finalizado_en,
                    i.duracion_segundos,
                    ue.consigna AS ultimo_ejercicio
                FROM intentos i
                INNER JOIN alumnos al ON al.id = i.alumno_id
                INNER JOIN actividades a ON a.id = i.actividad_id
                LEFT JOIN ejercicios ue ON ue.id = i.ultimo_ejercicio_id
                LEFT JOIN inscripciones ins ON ins.alumno_id = al.id AND ins.activo = 1
                LEFT JOIN cursos c ON c.id = ins.curso_id";
        $params = [];
        $where = [];

        if ($cursoId) {
            $where[] = 'c.id = ?';
            $params[] = $cursoId;
        }

        if ($actividadId) {
            $where[] = 'a.id = ?';
            $params[] = $actividadId;
        }

        if ($estado) {
            $where[] = 'i.estado = ?';
            $params[] = $estado;
        }

        if ($soloPendientes) {
            $where[] = "EXISTS (
                SELECT 1 FROM respuestas r
                WHERE r.intento_id = i.id AND r.estado_revision = 'pendiente'
            )";
        }

        if ($where) {
            $sql .= ' WHERE ' . implode(' AND ', $where);
        }

        $sql .= ' ORDER BY i.ultimo_acceso_en DESC, i.id DESC LIMIT 200';
        $stmt = db()->prepare($sql);
        $stmt->execute($params);

        return $stmt->fetchAll();
    }

    public function detalleIntento(int $intentoId): array
    {
        $stmt = db()->prepare(
            "SELECT
                r.id,
                r.intento_id,
                r.ejercicio_id,
                e.orden,
                e.codigo,
                e.consigna,
                r.respuesta_texto,
                r.respuesta_numero,
                r.correcta,
                r.estado_revision,
                r.puntos_docente,
                r.comentario_docente,
                r.revisado_en,
                r.respondido_en
             FROM respuestas r
             INNER JOIN ejercicios e ON e.id = r.ejercicio_id
             WHERE r.intento_id = ?
             ORDER BY e.orden, r.id"
        );
        $stmt->execute([$intentoId]);

        return $stmt->fetchAll();
    }

    public function corregirRespuesta(int $respuestaId, array $data): array
    {
        $estado = input_string($data, 'estado_revision', 'pendiente');
        if (!in_array($estado, ['pendiente', 'correcta', 'incorrecta'], true)) {
            throw new InvalidArgumentException('Estado de revisión no válido.');
        }

        $correcta = $estado === 'correcta' ? 1 : 0;
        $comentario = input_string($data, 'comentario_docente');
        $puntosDocente = array_key_exists('puntos_docente', $data) && $data['puntos_docente'] !== ''
            ? (float) $data['puntos_docente']
            : null;

        $pdo = db();
        $pdo->beginTransaction();

        try {
            $stmt = $pdo->prepare(
                "UPDATE respuestas
                 SET estado_revision = ?, correcta = ?, puntos_docente = ?, comentario_docente = ?, revisado_en = NOW()
                 WHERE id = ?"
            );
            $stmt->execute([$estado, $correcta, $puntosDocente, $comentario, $respuestaId]);

            $stmt = $pdo->prepare('SELECT intento_id FROM respuestas WHERE id = ? LIMIT 1');
            $stmt->execute([$respuestaId]);
            $intentoId = (int) $stmt->fetchColumn();

            if ($intentoId > 0) {
                $stmt = $pdo->prepare(
                    "UPDATE intentos
                     SET correctas = (
                       SELECT COUNT(*) FROM respuestas WHERE intento_id = ? AND correcta = 1
                     )
                     WHERE id = ?"
                );
                $stmt->execute([$intentoId, $intentoId]);
            }

            $pdo->commit();

            $stmt = db()->prepare(
                'SELECT id, intento_id, ejercicio_id, respuesta_texto, respuesta_numero, correcta,
                        estado_revision, puntos_docente, comentario_docente, revisado_en, respondido_en
                 FROM respuestas WHERE id = ? LIMIT 1'
            );
            $stmt->execute([$respuestaId]);
            $row = $stmt->fetch();

            if (!$row) {
                throw new InvalidArgumentException('No encontramos esa respuesta.');
            }

            return $row;
        } catch (Throwable $exception) {
            $pdo->rollBack();
            throw $exception;
        }
    }

    public function resumenAlumno(int $alumnoId): array
    {
        $stmt = db()->prepare(
            "SELECT id, dni, nombre, fecha_nacimiento FROM alumnos WHERE id = ? LIMIT 1"
        );
        $stmt->execute([$alumnoId]);
        $alumno = $stmt->fetch();

        if (!$alumno) {
            throw new InvalidArgumentException('No encontramos ese alumno.');
        }

        $stmt = db()->prepare(
            "SELECT
                i.id AS intento_id,
                a.titulo AS actividad,
                i.modo,
                i.estado,
                i.correctas,
                i.cantidad_respuestas,
                i.puntaje,
                i.iniciado_en,
                i.finalizado_en,
                i.duracion_segundos
             FROM intentos i
             INNER JOIN actividades a ON a.id = i.actividad_id
             WHERE i.alumno_id = ?
             ORDER BY i.ultimo_acceso_en DESC"
        );
        $stmt->execute([$alumnoId]);
        $intentos = $stmt->fetchAll();

        $stmt = db()->prepare(
            "SELECT
                COUNT(*) AS respuestas,
                SUM(CASE WHEN r.estado_revision = 'pendiente' THEN 1 ELSE 0 END) AS pendientes,
                SUM(CASE WHEN r.correcta = 1 THEN 1 ELSE 0 END) AS correctas,
                COALESCE(SUM(r.puntos_docente), 0) AS puntos_docente
             FROM respuestas r
             INNER JOIN intentos i ON i.id = r.intento_id
             WHERE i.alumno_id = ?"
        );
        $stmt->execute([$alumnoId]);
        $resumen = $stmt->fetch();

        return [
            'alumno' => $alumno,
            'totales' => [
                'intentos' => count($intentos),
                'respuestas' => (int) ($resumen['respuestas'] ?? 0),
                'pendientes' => (int) ($resumen['pendientes'] ?? 0),
                'correctas' => (int) ($resumen['correctas'] ?? 0),
                'puntos_docente' => (float) ($resumen['puntos_docente'] ?? 0),
                'tiempo_segundos' => array_sum(array_map(fn (array $row): int => (int) $row['duracion_segundos'], $intentos)),
            ],
            'intentos' => $intentos,
        ];
    }

    public function planillaPuntos(?int $cursoId = null): array
    {
        $pdo = db();
        $actividades = $pdo->query(
            'SELECT id, titulo, puntos, puntaje_habilitado, visible_alumno, acceso_habilitado, estado, orden
             FROM actividades
             WHERE visible_alumno = 1 OR puntaje_habilitado = 1
             ORDER BY orden, id'
        )->fetchAll();

        $alumnos = $this->listarAlumnos($cursoId);
        $actividadIds = array_map(fn (array $row): int => (int) $row['id'], $actividades);
        $alumnoIds = array_map(fn (array $row): int => (int) $row['id'], $alumnos);

        $puntosPorAlumno = [];
        foreach ($alumnos as $alumno) {
            $puntosPorAlumno[(int) $alumno['id']] = [
                'id' => (int) $alumno['id'],
                'dni' => (string) $alumno['dni'],
                'nombre' => (string) $alumno['nombre'],
                'curso' => $alumno['curso'] ? (string) $alumno['curso'] : null,
                'points' => [],
                'total' => 0,
            ];
        }

        if ($actividadIds && $alumnoIds) {
            $activityPlaceholders = implode(',', array_fill(0, count($actividadIds), '?'));
            $studentPlaceholders = implode(',', array_fill(0, count($alumnoIds), '?'));
            $stmt = $pdo->prepare(
                "SELECT alumno_id, actividad_id, COALESCE(SUM(puntos), 0) AS puntos
                 FROM movimientos_puntos
                 WHERE actividad_id IN ({$activityPlaceholders})
                   AND alumno_id IN ({$studentPlaceholders})
                 GROUP BY alumno_id, actividad_id"
            );
            $stmt->execute([...$actividadIds, ...$alumnoIds]);

            foreach ($stmt->fetchAll() as $row) {
                $alumnoId = (int) $row['alumno_id'];
                $actividadId = (int) $row['actividad_id'];
                $puntos = (int) $row['puntos'];

                if (!isset($puntosPorAlumno[$alumnoId])) {
                    continue;
                }

                $puntosPorAlumno[$alumnoId]['points'][(string) $actividadId] = $puntos;
                $puntosPorAlumno[$alumnoId]['total'] += $puntos;
            }
        }

        return [
            'activities' => array_map(
                fn (array $row): array => [
                    'id' => (int) $row['id'],
                    'title' => (string) $row['titulo'],
                    'points' => (int) $row['puntos'],
                    'pointsEnabled' => (bool) $row['puntaje_habilitado'],
                    'visible' => (bool) $row['visible_alumno'],
                    'accessEnabled' => (bool) $row['acceso_habilitado'],
                    'state' => (string) $row['estado'],
                ],
                $actividades
            ),
            'students' => array_values($puntosPorAlumno),
        ];
    }

    private function obtenerPorId(string $table, int $id): array
    {
        $allowed = ['cursos', 'temas', 'secciones_tp'];
        if (!in_array($table, $allowed, true)) {
            throw new InvalidArgumentException('Tabla no permitida.');
        }

        $stmt = db()->prepare("SELECT * FROM {$table} WHERE id = ? LIMIT 1");
        $stmt->execute([$id]);
        $row = $stmt->fetch();

        if (!$row) {
            throw new InvalidArgumentException('No encontramos el registro.');
        }

        return $row;
    }
}
