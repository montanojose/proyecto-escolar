USE electrodesafio;

ALTER TABLE respuestas
  ADD COLUMN IF NOT EXISTS estado_revision VARCHAR(20) NOT NULL DEFAULT 'pendiente' AFTER correcta,
  ADD COLUMN IF NOT EXISTS puntos_docente DECIMAL(6,2) NULL AFTER estado_revision,
  ADD COLUMN IF NOT EXISTS comentario_docente TEXT NULL AFTER estado_revision,
  ADD COLUMN IF NOT EXISTS revisado_en DATETIME NULL AFTER comentario_docente;
