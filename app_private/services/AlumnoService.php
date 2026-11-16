<?php

declare(strict_types=1);

require_once dirname(__DIR__) . '/config/database.php';

final class AlumnoService
{
    public function buscarOCrearPorDni(string $dni): array
    {
        $dni = preg_replace('/\D+/', '', $dni) ?? '';

        if (strlen($dni) < 7 || strlen($dni) > 10) {
            throw new InvalidArgumentException('Ingresá un DNI válido de 7 a 10 cifras.');
        }

        $pdo = db();
        $stmt = $pdo->prepare('SELECT id, dni, nombre, apellido FROM alumnos WHERE dni = ? LIMIT 1');
        $stmt->execute([$dni]);
        $alumno = $stmt->fetch();

        if (!$alumno) {
            throw new InvalidArgumentException('Usuario no registrado. Revisa el DNI o avisale al profesor.');
        }

        $stmt = $pdo->prepare('SELECT COUNT(*) FROM inscripciones WHERE alumno_id = ? AND activo = 1');
        $stmt->execute([(int) $alumno['id']]);
        if ((int) $stmt->fetchColumn() === 0) {
            throw new InvalidArgumentException('Tu inscripción todavía no fue validada por la profesora.');
        }

        return $this->mapear($alumno);
    }

    public function obtener(int $id): ?array
    {
        $stmt = db()->prepare('SELECT id, dni, nombre, apellido FROM alumnos WHERE id = ? LIMIT 1');
        $stmt->execute([$id]);
        $alumno = $stmt->fetch();

        return $alumno ? $this->mapear($alumno) : null;
    }

    private function mapear(array $alumno): array
    {
        return [
            'id' => (int) $alumno['id'],
            'dni' => (string) $alumno['dni'],
            'name' => trim((string) $alumno['nombre'] . ' ' . (string) ($alumno['apellido'] ?? '')),
        ];
    }
}
