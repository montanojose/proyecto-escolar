CREATE DATABASE IF NOT EXISTS materias_mica
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE materias_mica;

CREATE TABLE IF NOT EXISTS materias (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(120) NOT NULL,
  slug VARCHAR(80) NOT NULL UNIQUE,
  descripcion TEXT NULL,
  creada_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS actividades (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  materia_id INT UNSIGNED NOT NULL,
  titulo VARCHAR(180) NOT NULL,
  descripcion TEXT NULL,
  visible_alumno TINYINT(1) NOT NULL DEFAULT 0,
  creada_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizada_en TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_actividades_materia
    FOREIGN KEY (materia_id) REFERENCES materias(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS consignas (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  actividad_id INT UNSIGNED NOT NULL,
  enunciado TEXT NOT NULL,
  tipo ENUM('texto', 'opcion_multiple', 'verdadero_falso') NOT NULL DEFAULT 'texto',
  orden INT UNSIGNED NOT NULL DEFAULT 1,
  creada_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_consignas_actividad
    FOREIGN KEY (actividad_id) REFERENCES actividades(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO materias (nombre, slug, descripcion) VALUES
  ('Lengua', 'lengua', 'Lectura, escritura y comprension de textos.'),
  ('Historia', 'historia', 'Procesos historicos, fuentes y lineas de tiempo.'),
  ('Ciencias Naturales', 'ciencias-naturales', 'Ambiente, seres vivos, materia y energia.')
ON DUPLICATE KEY UPDATE
  nombre = VALUES(nombre),
  descripcion = VALUES(descripcion);
