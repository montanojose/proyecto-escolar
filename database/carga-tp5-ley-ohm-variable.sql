USE electrodesafio;

START TRANSACTION;

SET @act1 := (SELECT a.id FROM actividades a INNER JOIN secciones_tp s ON s.id = a.seccion_tp_id WHERE a.titulo = 'TP5 - Seccion 1' AND s.orden = 10 LIMIT 1);
SET @act2 := (SELECT a.id FROM actividades a INNER JOIN secciones_tp s ON s.id = a.seccion_tp_id WHERE a.titulo = 'TP5 - Seccion 2' AND s.orden = 20 LIMIT 1);
SET @act3 := (SELECT a.id FROM actividades a INNER JOIN secciones_tp s ON s.id = a.seccion_tp_id WHERE a.titulo = 'TP5 - Seccion 3' AND s.orden = 30 LIMIT 1);
SET @sec1 := (SELECT seccion_tp_id FROM actividades WHERE id = @act1 LIMIT 1);
SET @sec2 := (SELECT seccion_tp_id FROM actividades WHERE id = @act2 LIMIT 1);
SET @sec3 := (SELECT seccion_tp_id FROM actividades WHERE id = @act3 LIMIT 1);

INSERT INTO ejercicios (actividad_id, seccion_tp_id, codigo, consigna, explicacion, formula_respuesta, tolerancia, orden, activo) VALUES
  (@act1, @sec1, 'tp5-ej01-corriente-circuitos', 'Observe tres circuitos simples. Circuito A: fuente de {V1} y resistencia de {R1}. Circuito B: fuente de {V2} y resistencia de {R2}. Circuito C: fuente de {V3} y resistencia de {R3}. Determine la corriente de cada circuito e indique cual posee la mayor y cual la menor corriente.', 'Calcule cada corriente con I = V / R y compare los resultados. Esta respuesta queda para revision docente porque incluye comparacion y desarrollo.', NULL, NULL, 10, 1),
  (@act1, @sec1, 'tp5-ej02-resistencia-circuitos', 'En un circuito simple se indican la tension aplicada {V} y la corriente {I}. Determine el valor de la resistencia conectada.', 'Use R = V / I. Responda en ohm.', 'V / I', 0.01, 20, 1),
  (@act1, @sec1, 'tp5-ej03-voltaje-circuitos', 'En un circuito simple se indican la resistencia {R} y la corriente {I}. Determine la tension de alimentacion necesaria.', 'Use V = I x R. Responda en volts.', 'I * R', 0.01, 30, 1),
  (@act1, @sec1, 'tp5-ej04-instrumentos', 'Para una fuente de {V} y una resistencia de {R}, indique como conectar un amperimetro y un voltimetro, si cada instrumento va en serie o paralelo, y calcule la lectura esperada de cada instrumento.', 'El amperimetro se conecta en serie y el voltimetro en paralelo. Calcule la corriente con I = V / R. Esta respuesta queda para revision docente.', NULL, NULL, 40, 1),
  (@act1, @sec1, 'tp5-ej05-corriente-basica', 'Determine la corriente para un circuito con tension {V} y resistencia {R}.', 'Use I = V / R. Responda en amperes.', 'V / R', 0.00001, 50, 1),
  (@act1, @sec1, 'tp5-ej06-corriente-prefijos', 'Determine la corriente para un circuito con tension {V} y resistencia {R}.', 'Convierta unidades si hace falta y use I = V / R. Responda en amperes.', 'V / R', 0.00001, 60, 1),
  (@act1, @sec1, 'tp5-ej07-corriente-bateria', 'Se conecta un resistor de {R} a traves de una bateria de {V}. Determine la corriente que circula por el resistor.', 'Use I = V / R. Responda en amperes.', 'V / R', 0.00001, 70, 1),
  (@act1, @sec1, 'tp5-ej08-colores-tolerancia', 'Cierto resistor tiene codigo de colores naranja, naranja, rojo, oro. Determine la corriente maxima y la corriente minima esperadas cuando se conecta a una fuente de 12 V.', 'Obtenga el valor nominal y tolerancia del resistor, luego aplique I = V / R. Esta respuesta queda para revision docente.', NULL, NULL, 80, 1),
  (@act1, @sec1, 'tp5-ej09-colores-corriente', 'Un resistor de cuatro bandas se conecta a una fuente de 25 V. Determine la corriente que circula si el codigo de colores es amarillo, violeta, naranja, plata.', 'Obtenga la resistencia por codigo de colores y luego aplique I = V / R. Esta respuesta queda para revision docente.', NULL, NULL, 90, 1),
  (@act1, @sec1, 'tp5-ej10-aplicacion-corriente', 'En una situacion practica se conecta una fuente de {V} a un resistor de {R}. Determine la corriente que deberia registrar un amperimetro conectado correctamente.', 'Use I = V / R. Responda en amperes.', 'V / R', 0.00001, 100, 1),
  (@act2, @sec2, 'tp5-ej11-voltaje-basico', 'Calcule el voltaje para una corriente {I} y una resistencia {R}.', 'Use V = I x R. Responda en volts.', 'I * R', 0.01, 10, 1),
  (@act2, @sec2, 'tp5-ej12-voltaje-prefijos', 'Calcule el voltaje para una corriente {I} y una resistencia {R}.', 'Convierta unidades si hace falta y use V = I x R. Responda en volts.', 'I * R', 0.01, 20, 1),
  (@act2, @sec2, 'tp5-ej13-aplicacion-voltaje', 'Durante la medicion de un circuito, un amperimetro indica {I}. Si el resistor conectado tiene un valor de {R}, determine la tension aplicada entre sus extremos.', 'Use V = I x R. Responda en volts.', 'I * R', 0.01, 30, 1),
  (@act3, @sec3, 'tp5-ej14-resistencia-basica', 'Encuentre la resistencia para una tension {V} y una corriente {I}.', 'Use R = V / I. Responda en ohm.', 'V / I', 0.01, 10, 1),
  (@act3, @sec3, 'tp5-ej15-resistencia-prefijos', 'Calcule la resistencia para una tension {V} y una corriente {I}.', 'Convierta unidades si hace falta y use R = V / I. Responda en ohm.', 'V / I', 0.01, 20, 1),
  (@act3, @sec3, 'tp5-ej16-aplicacion-resistencia', 'En un circuito se mide una tension de {V} y una corriente de {I}. Determine el valor de la resistencia conectada.', 'Use R = V / I. Responda en ohm.', 'V / I', 0.01, 30, 1)
ON DUPLICATE KEY UPDATE
  actividad_id = VALUES(actividad_id),
  seccion_tp_id = VALUES(seccion_tp_id),
  consigna = VALUES(consigna),
  explicacion = VALUES(explicacion),
  formula_respuesta = VALUES(formula_respuesta),
  tolerancia = VALUES(tolerancia),
  orden = VALUES(orden),
  activo = VALUES(activo);

UPDATE combinaciones_ejercicio ce
INNER JOIN ejercicios e ON e.id = ce.ejercicio_id
SET ce.activa = 0
WHERE e.codigo LIKE 'tp5-%';

CREATE TEMPORARY TABLE tp5_combos (
  codigo VARCHAR(80) NOT NULL,
  combo_key VARCHAR(80) NOT NULL,
  nombre VARCHAR(20) NOT NULL,
  valor DECIMAL(14,4) NOT NULL,
  respuesta_numero DECIMAL(18,6) NULL,
  respuesta_texto VARCHAR(160) NULL,
  PRIMARY KEY (codigo, combo_key, nombre)
) ENGINE=Memory;

CREATE TEMPORARY TABLE tp5_seed (
  n INT PRIMARY KEY,
  v DECIMAL(14,4) NOT NULL,
  r DECIMAL(14,4) NOT NULL,
  i DECIMAL(14,6) NOT NULL
) ENGINE=Memory;

INSERT INTO tp5_seed (n, v, r, i) VALUES
  (1, 5, 10, 0.001),
  (2, 15, 10, 0.002),
  (3, 50, 100, 0.005),
  (4, 30, 15000, 0.010),
  (5, 250, 5600000, 0.020),
  (6, 9, 2700, 0.025),
  (7, 5.5, 10000, 0.050),
  (8, 40, 68000, 0.075),
  (9, 1000, 2200, 0.100),
  (10, 66000, 10000000, 0.250),
  (11, 12, 10, 0.00025),
  (12, 24, 1200, 0.00050),
  (13, 7, 470, 0.00075),
  (14, 36, 220, 0.003),
  (15, 90, 4700, 0.016),
  (16, 120, 1000, 0.030),
  (17, 3.3, 330, 0.040),
  (18, 18, 1800, 0.060),
  (19, 48, 2400, 0.080),
  (20, 110, 5500, 0.500);

INSERT INTO tp5_combos
SELECT 'tp5-ej05-corriente-basica', CONCAT('n', n), 'V', v, v / r, CONCAT(CAST(ROUND(v / r, 6) AS CHAR), ' A') FROM tp5_seed;
INSERT INTO tp5_combos
SELECT 'tp5-ej05-corriente-basica', CONCAT('n', n), 'R', r, v / r, CONCAT(CAST(ROUND(v / r, 6) AS CHAR), ' A') FROM tp5_seed;
INSERT INTO tp5_combos
SELECT 'tp5-ej06-corriente-prefijos', CONCAT('n', n), 'V', v, v / r, CONCAT(CAST(ROUND(v / r, 6) AS CHAR), ' A') FROM tp5_seed;
INSERT INTO tp5_combos
SELECT 'tp5-ej06-corriente-prefijos', CONCAT('n', n), 'R', r, v / r, CONCAT(CAST(ROUND(v / r, 6) AS CHAR), ' A') FROM tp5_seed;
INSERT INTO tp5_combos
SELECT 'tp5-ej07-corriente-bateria', CONCAT('n', n), 'V', v, v / r, CONCAT(CAST(ROUND(v / r, 6) AS CHAR), ' A') FROM tp5_seed;
INSERT INTO tp5_combos
SELECT 'tp5-ej07-corriente-bateria', CONCAT('n', n), 'R', r, v / r, CONCAT(CAST(ROUND(v / r, 6) AS CHAR), ' A') FROM tp5_seed;
INSERT INTO tp5_combos
SELECT 'tp5-ej10-aplicacion-corriente', CONCAT('n', n), 'V', v, v / r, CONCAT(CAST(ROUND(v / r, 6) AS CHAR), ' A') FROM tp5_seed;
INSERT INTO tp5_combos
SELECT 'tp5-ej10-aplicacion-corriente', CONCAT('n', n), 'R', r, v / r, CONCAT(CAST(ROUND(v / r, 6) AS CHAR), ' A') FROM tp5_seed;

INSERT INTO tp5_combos
SELECT 'tp5-ej02-resistencia-circuitos', CONCAT('n', n), 'V', v, v / i, CONCAT(CAST(ROUND(v / i, 2) AS CHAR), ' ohm') FROM tp5_seed;
INSERT INTO tp5_combos
SELECT 'tp5-ej02-resistencia-circuitos', CONCAT('n', n), 'I', i, v / i, CONCAT(CAST(ROUND(v / i, 2) AS CHAR), ' ohm') FROM tp5_seed;
INSERT INTO tp5_combos
SELECT 'tp5-ej14-resistencia-basica', CONCAT('n', n), 'V', v, v / i, CONCAT(CAST(ROUND(v / i, 2) AS CHAR), ' ohm') FROM tp5_seed;
INSERT INTO tp5_combos
SELECT 'tp5-ej14-resistencia-basica', CONCAT('n', n), 'I', i, v / i, CONCAT(CAST(ROUND(v / i, 2) AS CHAR), ' ohm') FROM tp5_seed;
INSERT INTO tp5_combos
SELECT 'tp5-ej15-resistencia-prefijos', CONCAT('n', n), 'V', v, v / i, CONCAT(CAST(ROUND(v / i, 2) AS CHAR), ' ohm') FROM tp5_seed;
INSERT INTO tp5_combos
SELECT 'tp5-ej15-resistencia-prefijos', CONCAT('n', n), 'I', i, v / i, CONCAT(CAST(ROUND(v / i, 2) AS CHAR), ' ohm') FROM tp5_seed;
INSERT INTO tp5_combos
SELECT 'tp5-ej16-aplicacion-resistencia', CONCAT('n', n), 'V', v, v / i, CONCAT(CAST(ROUND(v / i, 2) AS CHAR), ' ohm') FROM tp5_seed;
INSERT INTO tp5_combos
SELECT 'tp5-ej16-aplicacion-resistencia', CONCAT('n', n), 'I', i, v / i, CONCAT(CAST(ROUND(v / i, 2) AS CHAR), ' ohm') FROM tp5_seed;

INSERT INTO tp5_combos
SELECT 'tp5-ej03-voltaje-circuitos', CONCAT('n', n), 'R', r, i * r, CONCAT(CAST(ROUND(i * r, 2) AS CHAR), ' V') FROM tp5_seed;
INSERT INTO tp5_combos
SELECT 'tp5-ej03-voltaje-circuitos', CONCAT('n', n), 'I', i, i * r, CONCAT(CAST(ROUND(i * r, 2) AS CHAR), ' V') FROM tp5_seed;
INSERT INTO tp5_combos
SELECT 'tp5-ej11-voltaje-basico', CONCAT('n', n), 'R', r, i * r, CONCAT(CAST(ROUND(i * r, 2) AS CHAR), ' V') FROM tp5_seed;
INSERT INTO tp5_combos
SELECT 'tp5-ej11-voltaje-basico', CONCAT('n', n), 'I', i, i * r, CONCAT(CAST(ROUND(i * r, 2) AS CHAR), ' V') FROM tp5_seed;
INSERT INTO tp5_combos
SELECT 'tp5-ej12-voltaje-prefijos', CONCAT('n', n), 'R', r, i * r, CONCAT(CAST(ROUND(i * r, 2) AS CHAR), ' V') FROM tp5_seed;
INSERT INTO tp5_combos
SELECT 'tp5-ej12-voltaje-prefijos', CONCAT('n', n), 'I', i, i * r, CONCAT(CAST(ROUND(i * r, 2) AS CHAR), ' V') FROM tp5_seed;
INSERT INTO tp5_combos
SELECT 'tp5-ej13-aplicacion-voltaje', CONCAT('n', n), 'R', r, i * r, CONCAT(CAST(ROUND(i * r, 2) AS CHAR), ' V') FROM tp5_seed;
INSERT INTO tp5_combos
SELECT 'tp5-ej13-aplicacion-voltaje', CONCAT('n', n), 'I', i, i * r, CONCAT(CAST(ROUND(i * r, 2) AS CHAR), ' V') FROM tp5_seed;

INSERT INTO tp5_combos
SELECT 'tp5-ej04-instrumentos', CONCAT('n', n), 'V', v, NULL, NULL FROM tp5_seed;
INSERT INTO tp5_combos
SELECT 'tp5-ej04-instrumentos', CONCAT('n', n), 'R', r, NULL, NULL FROM tp5_seed;

INSERT INTO tp5_combos
SELECT 'tp5-ej01-corriente-circuitos', CONCAT('n', n), 'V1', v, NULL, NULL FROM tp5_seed;
INSERT INTO tp5_combos
SELECT 'tp5-ej01-corriente-circuitos', CONCAT('n', n), 'R1', r, NULL, NULL FROM tp5_seed;
INSERT INTO tp5_combos
SELECT 'tp5-ej01-corriente-circuitos', CONCAT('n', n), 'V2', v + 10, NULL, NULL FROM tp5_seed;
INSERT INTO tp5_combos
SELECT 'tp5-ej01-corriente-circuitos', CONCAT('n', n), 'R2', r + 100, NULL, NULL FROM tp5_seed;
INSERT INTO tp5_combos
SELECT 'tp5-ej01-corriente-circuitos', CONCAT('n', n), 'V3', v + 20, NULL, NULL FROM tp5_seed;
INSERT INTO tp5_combos
SELECT 'tp5-ej01-corriente-circuitos', CONCAT('n', n), 'R3', r + 220, NULL, NULL FROM tp5_seed;

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, nombre, etiqueta, descripcion, orden)
SELECT e.id,
       CASE WHEN c.nombre LIKE 'R%' THEN 1 WHEN c.nombre LIKE 'V%' THEN 2 ELSE 3 END,
       CASE WHEN c.nombre LIKE 'R%' THEN 1 WHEN c.nombre LIKE 'V%' THEN 2 ELSE 3 END,
       c.nombre,
       c.nombre,
       'Variable asignada automaticamente para el alumno.',
       CASE c.nombre WHEN 'V' THEN 10 WHEN 'R' THEN 20 WHEN 'I' THEN 30 WHEN 'V1' THEN 10 WHEN 'R1' THEN 20 WHEN 'V2' THEN 30 WHEN 'R2' THEN 40 WHEN 'V3' THEN 50 WHEN 'R3' THEN 60 ELSE 100 END
FROM (SELECT DISTINCT codigo, nombre FROM tp5_combos) c
INNER JOIN ejercicios e ON e.codigo = c.codigo
ON DUPLICATE KEY UPDATE
  magnitud_id = VALUES(magnitud_id),
  unidad_id = VALUES(unidad_id),
  etiqueta = VALUES(etiqueta),
  descripcion = VALUES(descripcion),
  orden = VALUES(orden);

INSERT INTO valores_variable (variable_ejercicio_id, valor, activo, orden)
SELECT DISTINCT ve.id, c.valor, 1, 10
FROM tp5_combos c
INNER JOIN ejercicios e ON e.codigo = c.codigo
INNER JOIN variables_ejercicio ve ON ve.ejercicio_id = e.id AND ve.nombre = c.nombre
ON DUPLICATE KEY UPDATE
  activo = VALUES(activo);

INSERT INTO combinaciones_ejercicio (ejercicio_id, codigo_hash, respuesta_numero, respuesta_texto, usos, activa)
SELECT e.id,
       SHA2(CONCAT(c.codigo, ':', c.combo_key), 256),
       MAX(c.respuesta_numero),
       MAX(c.respuesta_texto),
       0,
       1
FROM tp5_combos c
INNER JOIN ejercicios e ON e.codigo = c.codigo
GROUP BY e.id, c.codigo, c.combo_key
ON DUPLICATE KEY UPDATE
  respuesta_numero = VALUES(respuesta_numero),
  respuesta_texto = VALUES(respuesta_texto),
  activa = VALUES(activa);

INSERT INTO combinacion_valores (combinacion_ejercicio_id, variable_ejercicio_id, valor_variable_id, valor)
SELECT ce.id, ve.id, vv.id, c.valor
FROM tp5_combos c
INNER JOIN ejercicios e ON e.codigo = c.codigo
INNER JOIN combinaciones_ejercicio ce ON ce.ejercicio_id = e.id AND ce.codigo_hash = SHA2(CONCAT(c.codigo, ':', c.combo_key), 256)
INNER JOIN variables_ejercicio ve ON ve.ejercicio_id = e.id AND ve.nombre = c.nombre
INNER JOIN valores_variable vv ON vv.variable_ejercicio_id = ve.id AND vv.valor = c.valor
ON DUPLICATE KEY UPDATE
  valor_variable_id = VALUES(valor_variable_id),
  valor = VALUES(valor);

DROP TEMPORARY TABLE tp5_combos;
DROP TEMPORARY TABLE tp5_seed;

COMMIT;
