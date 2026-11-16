USE electrodesafio;
SET NAMES utf8mb4;

CREATE TEMPORARY TABLE tmp_alumnos_import (
  curso_id INT UNSIGNED NOT NULL,
  dni VARCHAR(10) NOT NULL,
  nombre VARCHAR(120) NOT NULL,
  fecha_nacimiento DATE NULL
) ENGINE=Memory;

INSERT INTO tmp_alumnos_import (curso_id, dni, nombre, fecha_nacimiento) VALUES
  (1, '90000022', 'Alumno de ejemplo 22', '2010-01-01'),
  (1, '90000023', 'Alumno de ejemplo 23', '2010-01-01'),
  (1, '90000024', 'Alumno de ejemplo 24', '2010-01-01'),
  (1, '90000025', 'Alumno de ejemplo 25', '2010-01-01'),
  (1, '90000026', 'Alumno de ejemplo 26', '2010-01-01'),
  (1, '90000027', 'Alumno de ejemplo 27', '2010-01-01'),
  (1, '90000028', 'Alumno de ejemplo 28', '2010-01-01'),
  (1, '90000029', 'Alumno de ejemplo 29', '2010-01-01'),
  (1, '90000030', 'Alumno de ejemplo 30', '2010-01-01'),
  (1, '90000031', 'Alumno de ejemplo 31', '2010-01-01'),
  (1, '90000032', 'Alumno de ejemplo 32', '2010-01-01'),
  (1, '90000033', 'Alumno de ejemplo 33', '2010-01-01'),
  (1, '90000034', 'Alumno de ejemplo 34', '2010-01-01'),
  (1, '90000035', 'Alumno de ejemplo 35', '2010-01-01'),
  (1, '90000036', 'Alumno de ejemplo 36', '2010-01-01'),
  (1, '90000037', 'Alumno de ejemplo 37', '2010-01-01'),
  (1, '90000038', 'Alumno de ejemplo 38', '2010-01-01'),
  (1, '90000039', 'Alumno de ejemplo 39', '2010-01-01'),
  (1, '90000040', 'Alumno de ejemplo 40', '2010-01-01'),
  (1, '90000041', 'Alumno de ejemplo 41', '2010-01-01'),
  (1, '90000042', 'Alumno de ejemplo 42', '2010-01-01'),
  (1, '90000043', 'Alumno de ejemplo 43', '2010-01-01'),
  (1, '90000044', 'Alumno de ejemplo 44', '2010-01-01'),
  (2, '90000045', 'Alumno de ejemplo 45', '2010-01-01'),
  (2, '90000046', 'Alumno de ejemplo 46', '2010-01-01'),
  (2, '90000047', 'Alumno de ejemplo 47', '2010-01-01'),
  (2, '90000048', 'Alumno de ejemplo 48', '2010-01-01'),
  (2, '90000049', 'Alumno de ejemplo 49', '2010-01-01'),
  (2, '90000050', 'Alumno de ejemplo 50', '2010-01-01'),
  (2, '90000051', 'Alumno de ejemplo 51', '2010-01-01'),
  (2, '90000052', 'Alumno de ejemplo 52', '2010-01-01'),
  (2, '90000053', 'Alumno de ejemplo 53', '2010-01-01'),
  (2, '90000054', 'Alumno de ejemplo 54', '2010-01-01'),
  (2, '90000055', 'Alumno de ejemplo 55', '2010-01-01'),
  (2, '90000056', 'Alumno de ejemplo 56', '2010-01-01'),
  (2, '90000057', 'Alumno de ejemplo 57', '2010-01-01'),
  (2, '90000058', 'Alumno de ejemplo 58', '2010-01-01');

UPDATE inscripciones
SET activo = 0
WHERE curso_id IN (1, 2)
  AND alumno_id NOT IN (
    SELECT a.id
    FROM alumnos a
    INNER JOIN tmp_alumnos_import t ON t.dni = a.dni
  );

INSERT INTO alumnos (dni, nombre, fecha_nacimiento)
SELECT dni, nombre, fecha_nacimiento
FROM tmp_alumnos_import
ON DUPLICATE KEY UPDATE
  nombre = VALUES(nombre),
  fecha_nacimiento = VALUES(fecha_nacimiento);

INSERT INTO inscripciones (alumno_id, curso_id, fecha_alta, activo)
SELECT a.id, t.curso_id, CURRENT_DATE, 1
FROM tmp_alumnos_import t
INNER JOIN alumnos a ON a.dni = t.dni
ON DUPLICATE KEY UPDATE
  activo = VALUES(activo),
  fecha_alta = VALUES(fecha_alta);
