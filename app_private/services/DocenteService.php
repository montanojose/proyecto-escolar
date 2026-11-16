<?php

declare(strict_types=1);

require_once dirname(__DIR__) . '/config/database.php';

final class DocenteService
{
    public function loginPorDni(string $dni): ?array
    {
        $dni = preg_replace('/\D+/', '', $dni) ?? '';
        if (strlen($dni) < 7 || strlen($dni) > 10) {
            return null;
        }

        $stmt = db()->prepare('SELECT id, dni, nombre, apellido, email FROM docentes WHERE dni = ? AND activo = 1 LIMIT 1');
        $stmt->execute([$dni]);
        $docente = $stmt->fetch();

        return $docente ? $this->mapearDocente($docente) : null;
    }

    public function registrar(array $data): array
    {
        $dni = preg_replace('/\D+/', '', input_string($data, 'dni')) ?? '';
        $nombre = input_string($data, 'nombre');
        $apellido = input_string($data, 'apellido');
        $email = input_string($data, 'email') ?: null;

        if (strlen($dni) < 7 || strlen($dni) > 10 || $nombre === '' || $apellido === '') {
            throw new InvalidArgumentException('Completá nombre, apellido y un DNI válido.');
        }

        $stmt = db()->prepare(
            'INSERT INTO docentes (dni, nombre, apellido, email, activo)
             VALUES (?, ?, ?, ?, 1)
             ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), apellido = VALUES(apellido), email = VALUES(email), activo = 1'
        );
        $stmt->execute([$dni, $nombre, $apellido, $email]);

        $docente = $this->loginPorDni($dni);
        if (!$docente) {
            throw new RuntimeException('No se pudo registrar el docente.');
        }

        return $docente;
    }

    public function crearClase(int $docenteId, array $data): array
    {
        $escuela = input_string($data, 'escuela');
        $materiaNombre = input_string($data, 'materia');
        $cursoNombre = input_string($data, 'curso');
        $anio = input_int($data, 'anio');
        $division = input_string($data, 'division');

        if ($escuela === '' || $materiaNombre === '' || $cursoNombre === '') {
            throw new InvalidArgumentException('Completá escuela, materia y curso.');
        }

        $pdo = db();
        $pdo->beginTransaction();

        try {
            $escuelaId = $this->obtenerOCrearEscuela($escuela);
            $materiaId = $this->obtenerOCrearMateria($materiaNombre);
            $cursoId = $this->obtenerOCrearCurso($materiaId, $cursoNombre, $anio, $division);
            $codigo = $this->generarCodigoClase($docenteId, $cursoId);

            $stmt = $pdo->prepare(
                'INSERT INTO clases_docente (docente_id, escuela_id, materia_id, curso_id, nombre, codigo, activa)
                 VALUES (?, ?, ?, ?, ?, ?, 1)
                 ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), activa = 1'
            );
            $stmt->execute([$docenteId, $escuelaId, $materiaId, $cursoId, $cursoNombre, $codigo]);

            $pdo->commit();
            return $this->obtenerClasePorCodigo($codigo);
        } catch (Throwable $exception) {
            $pdo->rollBack();
            throw $exception;
        }
    }

    public function listarClases(int $docenteId): array
    {
        $stmt = db()->prepare(
            "SELECT cd.id, cd.nombre, cd.codigo, cd.activa, e.nombre AS escuela, m.nombre AS materia,
                    c.nombre AS curso, c.ciclo_lectivo,
                    SUM(CASE WHEN ic.estado = 'pendiente' THEN 1 ELSE 0 END) AS pendientes,
                    SUM(CASE WHEN ic.estado = 'validada' THEN 1 ELSE 0 END) AS validados
             FROM clases_docente cd
             INNER JOIN escuelas e ON e.id = cd.escuela_id
             INNER JOIN materias m ON m.id = cd.materia_id
             INNER JOIN cursos c ON c.id = cd.curso_id
             LEFT JOIN inscripciones_clase ic ON ic.clase_id = cd.id
             WHERE cd.docente_id = ?
             GROUP BY cd.id
             ORDER BY cd.creado_en DESC"
        );
        $stmt->execute([$docenteId]);
        return $stmt->fetchAll();
    }

    public function listarInscripciones(int $docenteId): array
    {
        $stmt = db()->prepare(
            "SELECT ic.id, ic.estado, ic.solicitada_en, ic.validada_en,
                    a.id AS alumno_id, a.dni, a.nombre, a.apellido,
                    cd.id AS clase_id, cd.codigo, cd.nombre AS clase,
                    e.nombre AS escuela, m.nombre AS materia, c.nombre AS curso
             FROM inscripciones_clase ic
             INNER JOIN clases_docente cd ON cd.id = ic.clase_id
             INNER JOIN alumnos a ON a.id = ic.alumno_id
             INNER JOIN escuelas e ON e.id = cd.escuela_id
             INNER JOIN materias m ON m.id = cd.materia_id
             INNER JOIN cursos c ON c.id = cd.curso_id
             WHERE cd.docente_id = ?
             ORDER BY FIELD(ic.estado, 'pendiente', 'validada', 'rechazada'), ic.solicitada_en DESC"
        );
        $stmt->execute([$docenteId]);
        return $stmt->fetchAll();
    }

    public function cambiarEstadoInscripcion(int $docenteId, int $inscripcionId, string $estado): array
    {
        if (!in_array($estado, ['validada', 'rechazada'], true)) {
            throw new InvalidArgumentException('Estado de inscripción inválido.');
        }

        $pdo = db();
        $pdo->beginTransaction();

        try {
            $stmt = $pdo->prepare(
                'SELECT ic.*, cd.curso_id
                 FROM inscripciones_clase ic
                 INNER JOIN clases_docente cd ON cd.id = ic.clase_id
                 WHERE ic.id = ? AND cd.docente_id = ?
                 LIMIT 1'
            );
            $stmt->execute([$inscripcionId, $docenteId]);
            $inscripcion = $stmt->fetch();

            if (!$inscripcion) {
                throw new InvalidArgumentException('No encontramos esa inscripción para este docente.');
            }

            $stmt = $pdo->prepare(
                'UPDATE inscripciones_clase
                 SET estado = ?, validada_en = NOW(), validada_por_docente_id = ?
                 WHERE id = ?'
            );
            $stmt->execute([$estado, $docenteId, $inscripcionId]);

            if ($estado === 'validada') {
                $stmt = $pdo->prepare(
                    'INSERT INTO inscripciones (alumno_id, curso_id, fecha_alta, activo)
                     VALUES (?, ?, CURRENT_DATE, 1)
                     ON DUPLICATE KEY UPDATE activo = 1, fecha_alta = VALUES(fecha_alta)'
                );
                $stmt->execute([(int) $inscripcion['alumno_id'], (int) $inscripcion['curso_id']]);
            }

            $pdo->commit();
            return ['id' => $inscripcionId, 'estado' => $estado];
        } catch (Throwable $exception) {
            $pdo->rollBack();
            throw $exception;
        }
    }

    public function registrarAlumnoEnClase(array $data): array
    {
        $dni = preg_replace('/\D+/', '', input_string($data, 'dni')) ?? '';
        $clave = preg_replace('/\D+/', '', input_string($data, 'clave')) ?? '';
        $nombre = input_string($data, 'nombre');
        $apellido = input_string($data, 'apellido');
        $codigo = strtoupper(input_string($data, 'codigo'));

        if (strlen($dni) < 7 || strlen($dni) > 10 || $nombre === '' || $apellido === '' || $codigo === '') {
            throw new InvalidArgumentException('Completá nombre, apellido, DNI y código de clase.');
        }
        if ($clave !== $dni) {
            throw new InvalidArgumentException('La contraseña inicial debe ser el DNI.');
        }

        $clase = $this->obtenerClasePorCodigo($codigo);
        if (!$clase || !(int) $clase['activa']) {
            throw new InvalidArgumentException('No encontramos una clase activa con ese código.');
        }

        $pdo = db();
        $pdo->beginTransaction();

        try {
            $stmt = $pdo->prepare(
                'INSERT INTO alumnos (dni, nombre, apellido, clave_hash, fecha_nacimiento)
                 VALUES (?, ?, ?, ?, NULL)
                 ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), apellido = VALUES(apellido), clave_hash = VALUES(clave_hash)'
            );
            $stmt->execute([$dni, $nombre, $apellido, password_hash($clave, PASSWORD_DEFAULT)]);

            $stmt = $pdo->prepare('SELECT id, dni, nombre, apellido FROM alumnos WHERE dni = ? LIMIT 1');
            $stmt->execute([$dni]);
            $alumno = $stmt->fetch();

            $stmt = $pdo->prepare(
                'INSERT INTO inscripciones_clase (clase_id, alumno_id, estado)
                 VALUES (?, ?, "pendiente")
                 ON DUPLICATE KEY UPDATE estado = IF(estado = "rechazada", "pendiente", estado)'
            );
            $stmt->execute([(int) $clase['id'], (int) $alumno['id']]);

            $pdo->commit();

            return [
                'student' => $alumno,
                'class' => $clase,
                'status' => 'pendiente',
            ];
        } catch (Throwable $exception) {
            $pdo->rollBack();
            throw $exception;
        }
    }

    public function obtenerClasePorCodigo(string $codigo): ?array
    {
        $stmt = db()->prepare(
            'SELECT cd.id, cd.nombre, cd.codigo, cd.activa, e.nombre AS escuela, m.nombre AS materia, c.nombre AS curso
             FROM clases_docente cd
             INNER JOIN escuelas e ON e.id = cd.escuela_id
             INNER JOIN materias m ON m.id = cd.materia_id
             INNER JOIN cursos c ON c.id = cd.curso_id
             WHERE cd.codigo = ?
             LIMIT 1'
        );
        $stmt->execute([strtoupper($codigo)]);
        $clase = $stmt->fetch();

        return $clase ?: null;
    }

    private function obtenerOCrearEscuela(string $nombre): int
    {
        $stmt = db()->prepare(
            'INSERT INTO escuelas (nombre, activo) VALUES (?, 1)
             ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id), activo = 1'
        );
        $stmt->execute([$nombre]);

        return (int) db()->query('SELECT LAST_INSERT_ID()')->fetchColumn();
    }

    private function obtenerOCrearMateria(string $nombre): int
    {
        $slug = strtolower(preg_replace('/[^a-z0-9]+/i', '-', trim($nombre)) ?? 'materia');
        $slug = trim($slug, '-') ?: 'materia';

        $stmt = db()->prepare(
            'INSERT INTO materias (nombre, slug, activo) VALUES (?, ?, 1)
             ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id), activo = 1'
        );
        $stmt->execute([$nombre, $slug]);

        return (int) db()->query('SELECT LAST_INSERT_ID()')->fetchColumn();
    }

    private function obtenerOCrearCurso(int $materiaId, string $nombre, int $anio, string $division): int
    {
        $stmt = db()->prepare(
            'INSERT INTO cursos (materia_id, anio, division, nombre, especialidad, turno, ciclo_lectivo, activo)
             VALUES (?, ?, ?, ?, NULL, NULL, YEAR(CURRENT_DATE), 1)
             ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id), materia_id = VALUES(materia_id), anio = VALUES(anio), division = VALUES(division), activo = 1'
        );
        $stmt->execute([$materiaId, $anio ?: null, $division ?: null, $nombre]);

        return (int) db()->query('SELECT LAST_INSERT_ID()')->fetchColumn();
    }

    private function generarCodigoClase(int $docenteId, int $cursoId): string
    {
        $base = strtoupper(substr(base_convert((string) ($docenteId * 100000 + $cursoId), 10, 36), 0, 5));
        $codigo = 'CL' . str_pad($base, 5, '0', STR_PAD_LEFT);
        $existe = $this->obtenerClasePorCodigo($codigo);

        return $existe ? $codigo . random_int(1, 9) : $codigo;
    }

    private function mapearDocente(array $docente): array
    {
        return [
            'id' => (int) $docente['id'],
            'dni' => (string) $docente['dni'],
            'nombre' => (string) $docente['nombre'],
            'apellido' => (string) ($docente['apellido'] ?? ''),
            'email' => $docente['email'] ?? null,
        ];
    }
}
