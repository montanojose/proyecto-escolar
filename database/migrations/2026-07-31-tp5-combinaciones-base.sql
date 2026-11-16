USE electrodesafio;

INSERT INTO combinaciones_ejercicio (ejercicio_id, codigo_hash, respuesta_numero, respuesta_texto, usos, activa)
SELECT id, SHA2(CONCAT(codigo, ':V=12;R=10'), 256), 1.2, '1.2 A', 0, 1
FROM ejercicios
WHERE codigo = 'tp5-ej07-corriente-bateria'
ON DUPLICATE KEY UPDATE
  respuesta_numero = VALUES(respuesta_numero),
  respuesta_texto = VALUES(respuesta_texto),
  activa = VALUES(activa);

INSERT INTO combinaciones_ejercicio (ejercicio_id, codigo_hash, respuesta_numero, respuesta_texto, usos, activa)
SELECT id, SHA2(CONCAT(codigo, ':I=2;R=18'), 256), 36, '36 V', 0, 1
FROM ejercicios
WHERE codigo = 'tp5-ej11-voltaje-basico'
ON DUPLICATE KEY UPDATE
  respuesta_numero = VALUES(respuesta_numero),
  respuesta_texto = VALUES(respuesta_texto),
  activa = VALUES(activa);

INSERT INTO combinaciones_ejercicio (ejercicio_id, codigo_hash, respuesta_numero, respuesta_texto, usos, activa)
SELECT id, SHA2(CONCAT(codigo, ':V=10;I=2'), 256), 5, '5 ohm', 0, 1
FROM ejercicios
WHERE codigo = 'tp5-ej14-resistencia-basica'
ON DUPLICATE KEY UPDATE
  respuesta_numero = VALUES(respuesta_numero),
  respuesta_texto = VALUES(respuesta_texto),
  activa = VALUES(activa);
