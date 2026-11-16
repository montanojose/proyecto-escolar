USE electrodesafio;

ALTER TABLE respuestas
  ADD COLUMN IF NOT EXISTS puntos_docente DECIMAL(6,2) NULL AFTER estado_revision;
