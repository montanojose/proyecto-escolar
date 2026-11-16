USE electrodesafio;
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO temas (nombre, descripcion, orden, activo) VALUES
  ('Matemática', 'Actividades autocorregibles de Matemática.', 6, 1)
ON DUPLICATE KEY UPDATE descripcion = VALUES(descripcion), orden = VALUES(orden), activo = VALUES(activo);

SET @tema_matematica := (SELECT id FROM temas WHERE nombre = 'Matemática' LIMIT 1);

INSERT INTO contenedores_actividad (tema_id, nombre, descripcion, orden, activo) VALUES
  (@tema_matematica, '5.º año', 'Actividades de función racional para 5.º año.', 10, 1)
ON DUPLICATE KEY UPDATE descripcion = VALUES(descripcion), orden = VALUES(orden), activo = VALUES(activo);

SET @contenedor_matematica := (
  SELECT id
  FROM contenedores_actividad
  WHERE tema_id = @tema_matematica AND nombre = '5.º año'
  LIMIT 1
);

INSERT INTO actividades (contenedor_id, seccion_tp_id, titulo, descripcion, nivel, puntos, estado, visible_alumno, acceso_habilitado, puntaje_habilitado, icono, orden)
SELECT @contenedor_matematica, NULL,
       'Aplicaciones de la función racional: calcular, observar e interpretar',
       'Recorrido progresivo con cálculos, tablas, gráficos e interpretación de modelos racionales.',
       '5.º año', 10, 'Disponible', 1, 1, 0, 'M', 20
WHERE NOT EXISTS (
  SELECT 1
  FROM actividades
  WHERE contenedor_id = @contenedor_matematica
    AND titulo = 'Aplicaciones de la función racional: calcular, observar e interpretar'
);

UPDATE actividades
SET descripcion = 'Recorrido progresivo con cálculos, tablas, gráficos e interpretación de modelos racionales.',
    nivel = '5.º año',
    puntos = 10,
    estado = 'Disponible',
    visible_alumno = 1,
    acceso_habilitado = 1,
    puntaje_habilitado = 0,
    icono = 'M',
    orden = 20
WHERE contenedor_id = @contenedor_matematica
  AND titulo = 'Aplicaciones de la función racional: calcular, observar e interpretar';

CREATE TABLE IF NOT EXISTS matematica_racional_progreso (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  alumno_id INT UNSIGNED NOT NULL,
  actividad_id INT UNSIGNED NOT NULL,
  intento_id INT UNSIGNED NULL,
  indice_a TINYINT UNSIGNED NOT NULL,
  indice_b TINYINT UNSIGNED NOT NULL,
  tarea_actual INT UNSIGNED NOT NULL DEFAULT 0,
  respuestas_json MEDIUMTEXT NOT NULL,
  intentos_json MEDIUMTEXT NOT NULL,
  completada TINYINT(1) NOT NULL DEFAULT 0,
  iniciado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ultimo_acceso_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  finalizado_en DATETIME NULL,
  UNIQUE KEY uq_matematica_racional_alumno_actividad (alumno_id, actividad_id),
  CONSTRAINT fk_matematica_racional_alumno FOREIGN KEY (alumno_id) REFERENCES alumnos(id) ON DELETE CASCADE,
  CONSTRAINT fk_matematica_racional_actividad FOREIGN KEY (actividad_id) REFERENCES actividades(id) ON DELETE CASCADE,
  CONSTRAINT fk_matematica_racional_intento FOREIGN KEY (intento_id) REFERENCES intentos(id) ON DELETE SET NULL,
  INDEX idx_matematica_racional_version (actividad_id, indice_a, indice_b),
  INDEX idx_matematica_racional_estado (actividad_id, completada, tarea_actual),
  CONSTRAINT chk_matematica_racional_indice_a CHECK (indice_a BETWEEN 1 AND 8),
  CONSTRAINT chk_matematica_racional_indice_b CHECK (indice_b BETWEEN 1 AND 8)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
