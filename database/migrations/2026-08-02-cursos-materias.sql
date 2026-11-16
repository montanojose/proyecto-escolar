USE electrodesafio;

CREATE TABLE IF NOT EXISTS materias (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(80) NOT NULL UNIQUE,
  slug VARCHAR(80) NOT NULL UNIQUE,
  activo TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO materias (id, nombre, slug, activo) VALUES
  (1, 'Electrotecnia I', 'electrotecnia-i', 1),
  (2, 'Electrotecnia II', 'electrotecnia-ii', 1)
ON DUPLICATE KEY UPDATE
  nombre = VALUES(nombre),
  slug = VALUES(slug),
  activo = VALUES(activo);

ALTER TABLE cursos
  ADD COLUMN IF NOT EXISTS materia_id INT UNSIGNED NULL AFTER id,
  ADD COLUMN IF NOT EXISTS anio TINYINT UNSIGNED NULL AFTER materia_id,
  ADD COLUMN IF NOT EXISTS division VARCHAR(10) NULL AFTER anio;

ALTER TABLE cursos
  ADD INDEX IF NOT EXISTS idx_cursos_materia (materia_id),
  ADD INDEX IF NOT EXISTS idx_cursos_ciclo_materia (ciclo_lectivo, materia_id, anio, division);

SET @fk_exists := (
  SELECT COUNT(*)
  FROM information_schema.TABLE_CONSTRAINTS
  WHERE CONSTRAINT_SCHEMA = DATABASE()
    AND TABLE_NAME = 'cursos'
    AND CONSTRAINT_NAME = 'fk_cursos_materia'
);

SET @fk_sql := IF(
  @fk_exists = 0,
  'ALTER TABLE cursos ADD CONSTRAINT fk_cursos_materia FOREIGN KEY (materia_id) REFERENCES materias(id) ON DELETE RESTRICT',
  'DO 0'
);

PREPARE fk_stmt FROM @fk_sql;
EXECUTE fk_stmt;
DEALLOCATE PREPARE fk_stmt;

UPDATE cursos
SET materia_id = 1,
    anio = 3,
    division = '1',
    nombre = '3 1 - Electrotecnia I',
    especialidad = 'Electrotecnia',
    activo = 1
WHERE id = 101;

UPDATE cursos
SET materia_id = 2,
    anio = 4,
    division = '1',
    nombre = '4 1 - Electrotecnia II',
    especialidad = 'Electrotecnia',
    activo = 1
WHERE id = 1;

DELETE c
FROM cursos c
LEFT JOIN inscripciones i ON i.curso_id = c.id
WHERE c.nombre = '4 3 - Electrotecnia II'
  AND c.id <> 2
  AND i.id IS NULL;

UPDATE cursos
SET materia_id = 2,
    anio = 4,
    division = '3',
    nombre = '4 3 - Electrotecnia II',
    especialidad = 'Electrotecnia',
    activo = 1
WHERE id = 2;

UPDATE cursos
SET activo = 0
WHERE id IN (2, 3)
  AND nombre IN ('5 1', '6 1');
