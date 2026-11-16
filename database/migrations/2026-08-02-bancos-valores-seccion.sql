USE electrodesafio;

START TRANSACTION;

CREATE TABLE IF NOT EXISTS bancos_valores_seccion (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  seccion_tp_id INT UNSIGNED NOT NULL,
  magnitud_id INT UNSIGNED NOT NULL,
  unidad_id INT UNSIGNED NOT NULL,
  nombre VARCHAR(80) NOT NULL,
  codigo VARCHAR(40) NOT NULL,
  descripcion VARCHAR(180) NULL,
  orden INT UNSIGNED NOT NULL DEFAULT 100,
  activo TINYINT(1) NOT NULL DEFAULT 1,
  UNIQUE KEY uq_banco_seccion_codigo (seccion_tp_id, codigo),
  CONSTRAINT fk_bancos_seccion
    FOREIGN KEY (seccion_tp_id) REFERENCES secciones_tp(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_bancos_magnitud
    FOREIGN KEY (magnitud_id) REFERENCES magnitudes(id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_bancos_unidad
    FOREIGN KEY (unidad_id) REFERENCES unidades(id)
    ON DELETE RESTRICT,
  INDEX idx_bancos_seccion (seccion_tp_id, activo, orden)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS valores_banco_seccion (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  banco_valores_seccion_id INT UNSIGNED NOT NULL,
  indice INT UNSIGNED NOT NULL,
  valor DECIMAL(14,4) NOT NULL,
  etiqueta VARCHAR(60) NULL,
  activo TINYINT(1) NOT NULL DEFAULT 1,
  UNIQUE KEY uq_valor_banco_indice (banco_valores_seccion_id, indice),
  UNIQUE KEY uq_valor_banco_valor (banco_valores_seccion_id, valor),
  CONSTRAINT fk_valores_banco
    FOREIGN KEY (banco_valores_seccion_id) REFERENCES bancos_valores_seccion(id)
    ON DELETE CASCADE,
  INDEX idx_valores_banco_activo (banco_valores_seccion_id, activo, indice)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE variables_ejercicio
  ADD COLUMN banco_valores_seccion_id INT UNSIGNED NULL AFTER unidad_id,
  ADD CONSTRAINT fk_variables_banco_seccion
    FOREIGN KEY (banco_valores_seccion_id) REFERENCES bancos_valores_seccion(id)
    ON DELETE SET NULL,
  ADD INDEX idx_variables_banco_seccion (banco_valores_seccion_id);

ALTER TABLE combinaciones_ejercicio
  ADD COLUMN codigo_combinacion VARCHAR(80) NULL AFTER codigo_hash,
  ADD COLUMN ciclo INT UNSIGNED NOT NULL DEFAULT 1 AFTER usos,
  ADD INDEX idx_combinaciones_codigo (ejercicio_id, codigo_combinacion);

DROP PROCEDURE IF EXISTS sp_asignar_combinacion;

COMMIT;
