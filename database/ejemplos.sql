USE electrodesafio;

INSERT INTO intentos (alumno_id, actividad_id, modo, estado, correctas, cantidad_respuestas, puntaje, finalizado_en, duracion_segundos)
VALUES
  (1, 1, 'evaluativo', 'finalizado', 8, 10, 10, NOW(), 620),
  (2, 1, 'evaluativo', 'finalizado', 7, 10, 10, NOW(), 710),
  (1, 2, 'practica', 'finalizado', 9, 12, 0, NOW(), 840);

INSERT INTO movimientos_puntos (alumno_id, actividad_id, intento_id, puntos, motivo)
SELECT alumno_id, actividad_id, id, puntaje, 'Carga de ejemplo'
FROM intentos
WHERE puntaje > 0;
