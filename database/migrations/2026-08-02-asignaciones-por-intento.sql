USE electrodesafio;

START TRANSACTION;

ALTER TABLE asignaciones_combinacion
  DROP INDEX uq_asignacion_alumno_ejercicio,
  ADD UNIQUE KEY uq_asignacion_intento_ejercicio (intento_id, ejercicio_id),
  ADD INDEX idx_asignacion_alumno_ejercicio (alumno_id, ejercicio_id);

COMMIT;
