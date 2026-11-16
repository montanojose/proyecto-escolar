SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS actividades_clase (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  clase_id INT UNSIGNED NOT NULL,
  actividad_id INT UNSIGNED NOT NULL,
  visible_alumno TINYINT(1) NOT NULL DEFAULT 1,
  acceso_habilitado TINYINT(1) NOT NULL DEFAULT 1,
  puntaje_habilitado TINYINT(1) NOT NULL DEFAULT 0,
  estado VARCHAR(40) NOT NULL DEFAULT 'Practica',
  fecha_inicio DATETIME NULL,
  fecha_cierre DATETIME NULL,
  orden INT UNSIGNED NOT NULL DEFAULT 100,
  configuracion_json MEDIUMTEXT NULL,
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_actividades_clase_clase FOREIGN KEY (clase_id) REFERENCES clases_docente(id) ON DELETE CASCADE,
  CONSTRAINT fk_actividades_clase_actividad FOREIGN KEY (actividad_id) REFERENCES actividades(id) ON DELETE CASCADE,
  UNIQUE KEY uq_actividades_clase (clase_id, actividad_id),
  INDEX idx_actividades_clase_estado (clase_id, visible_alumno, acceso_habilitado, puntaje_habilitado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET @intentos_actividad_clase_exists := (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'intentos' AND COLUMN_NAME = 'actividad_clase_id'
);
SET @sql := IF(@intentos_actividad_clase_exists = 0, 'ALTER TABLE intentos ADD COLUMN actividad_clase_id INT UNSIGNED NULL AFTER actividad_id', 'DO 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @intentos_clase_exists := (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'intentos' AND COLUMN_NAME = 'clase_id'
);
SET @sql := IF(@intentos_clase_exists = 0, 'ALTER TABLE intentos ADD COLUMN clase_id INT UNSIGNED NULL AFTER actividad_clase_id', 'DO 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @movimientos_actividad_clase_exists := (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'movimientos_puntos' AND COLUMN_NAME = 'actividad_clase_id'
);
SET @sql := IF(@movimientos_actividad_clase_exists = 0, 'ALTER TABLE movimientos_puntos ADD COLUMN actividad_clase_id INT UNSIGNED NULL AFTER actividad_id', 'DO 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
