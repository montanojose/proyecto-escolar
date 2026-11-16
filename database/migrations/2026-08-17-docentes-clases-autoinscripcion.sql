SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

SET @docentes_dni_exists := (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'docentes' AND COLUMN_NAME = 'dni'
);
SET @sql := IF(@docentes_dni_exists = 0, 'ALTER TABLE docentes ADD COLUMN dni VARCHAR(10) NULL UNIQUE AFTER id', 'DO 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @docentes_apellido_exists := (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'docentes' AND COLUMN_NAME = 'apellido'
);
SET @sql := IF(@docentes_apellido_exists = 0, 'ALTER TABLE docentes ADD COLUMN apellido VARCHAR(120) NULL AFTER nombre', 'DO 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @docentes_activo_exists := (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'docentes' AND COLUMN_NAME = 'activo'
);
SET @sql := IF(@docentes_activo_exists = 0, 'ALTER TABLE docentes ADD COLUMN activo TINYINT(1) NOT NULL DEFAULT 1 AFTER email', 'DO 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

CREATE TABLE IF NOT EXISTS escuelas (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(160) NOT NULL UNIQUE,
  activo TINYINT(1) NOT NULL DEFAULT 1,
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS clases_docente (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  docente_id INT UNSIGNED NOT NULL,
  escuela_id INT UNSIGNED NOT NULL,
  materia_id INT UNSIGNED NOT NULL,
  curso_id INT UNSIGNED NOT NULL,
  nombre VARCHAR(160) NOT NULL,
  codigo VARCHAR(16) NOT NULL UNIQUE,
  activa TINYINT(1) NOT NULL DEFAULT 1,
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_clases_docente_docente FOREIGN KEY (docente_id) REFERENCES docentes(id) ON DELETE CASCADE,
  CONSTRAINT fk_clases_docente_escuela FOREIGN KEY (escuela_id) REFERENCES escuelas(id) ON DELETE RESTRICT,
  CONSTRAINT fk_clases_docente_materia FOREIGN KEY (materia_id) REFERENCES materias(id) ON DELETE RESTRICT,
  CONSTRAINT fk_clases_docente_curso FOREIGN KEY (curso_id) REFERENCES cursos(id) ON DELETE RESTRICT,
  INDEX idx_clases_docente_docente (docente_id, activa),
  INDEX idx_clases_docente_curso (curso_id, activa)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS inscripciones_clase (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  clase_id INT UNSIGNED NOT NULL,
  alumno_id INT UNSIGNED NOT NULL,
  estado ENUM('pendiente','validada','rechazada') NOT NULL DEFAULT 'pendiente',
  solicitada_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  validada_en DATETIME NULL,
  validada_por_docente_id INT UNSIGNED NULL,
  CONSTRAINT fk_inscripciones_clase_clase FOREIGN KEY (clase_id) REFERENCES clases_docente(id) ON DELETE CASCADE,
  CONSTRAINT fk_inscripciones_clase_alumno FOREIGN KEY (alumno_id) REFERENCES alumnos(id) ON DELETE CASCADE,
  CONSTRAINT fk_inscripciones_clase_validador FOREIGN KEY (validada_por_docente_id) REFERENCES docentes(id) ON DELETE SET NULL,
  UNIQUE KEY uq_inscripcion_clase_alumno (clase_id, alumno_id),
  INDEX idx_inscripciones_clase_estado (clase_id, estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET @alumnos_apellido_exists := (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'alumnos' AND COLUMN_NAME = 'apellido'
);
SET @sql := IF(@alumnos_apellido_exists = 0, 'ALTER TABLE alumnos ADD COLUMN apellido VARCHAR(120) NULL AFTER nombre', 'DO 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @alumnos_clave_exists := (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'alumnos' AND COLUMN_NAME = 'clave_hash'
);
SET @sql := IF(@alumnos_clave_exists = 0, 'ALTER TABLE alumnos ADD COLUMN clave_hash VARCHAR(255) NULL AFTER fecha_nacimiento', 'DO 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

INSERT INTO docentes (id, dni, nombre, apellido, email, activo)
VALUES (1, '42082348', 'Profesor', 'Electrotecnia', NULL, 1)
ON DUPLICATE KEY UPDATE
  dni = VALUES(dni),
  nombre = VALUES(nombre),
  apellido = VALUES(apellido),
  activo = VALUES(activo);
