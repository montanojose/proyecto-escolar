USE electrodesafio;

START TRANSACTION;

UPDATE ejercicios
SET consigna = 'Observe un circuito simple con tension {V} y resistencia {R}. Determine la corriente que circula por el circuito.',
    explicacion = 'Use I = V / R.',
    formula_respuesta = 'V / R',
    tolerancia = 0.05,
    activo = 1
WHERE codigo = 'tp5-ej01-corriente-circuitos';

UPDATE ejercicios
SET tolerancia = 0.05
WHERE codigo LIKE 'tp5-%' AND formula_respuesta IS NOT NULL;

UPDATE ejercicios
SET activo = 0
WHERE codigo IN (
  'tp5-ej04-instrumentos',
  'tp5-ej08-colores-tolerancia',
  'tp5-ej09-colores-corriente'
);

UPDATE combinaciones_ejercicio ce
INNER JOIN ejercicios e ON e.id = ce.ejercicio_id
SET ce.activa = 0
WHERE e.codigo = 'tp5-ej01-corriente-circuitos';

CREATE TEMPORARY TABLE tp5_ej01_seed (
  n INT PRIMARY KEY,
  v DECIMAL(14,4) NOT NULL,
  r DECIMAL(14,4) NOT NULL
) ENGINE=Memory;

INSERT INTO tp5_ej01_seed (n, v, r) VALUES
  (1, 5, 10),
  (2, 15, 10),
  (3, 50, 100),
  (4, 30, 15000),
  (5, 250, 5600000),
  (6, 9, 2700),
  (7, 5.5, 10000),
  (8, 40, 68000),
  (9, 1000, 2200),
  (10, 66000, 10000000),
  (11, 12, 10),
  (12, 24, 1200),
  (13, 7, 470),
  (14, 36, 220),
  (15, 90, 4700),
  (16, 120, 1000),
  (17, 3.3, 330),
  (18, 18, 1800),
  (19, 48, 2400),
  (20, 110, 5500);

SET @ej01 := (SELECT id FROM ejercicios WHERE codigo = 'tp5-ej01-corriente-circuitos' LIMIT 1);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, nombre, etiqueta, descripcion, orden) VALUES
  (@ej01, 2, 2, 'V', 'V', 'Tension asignada automaticamente.', 10),
  (@ej01, 1, 1, 'R', 'R', 'Resistencia asignada automaticamente.', 20)
ON DUPLICATE KEY UPDATE
  magnitud_id = VALUES(magnitud_id),
  unidad_id = VALUES(unidad_id),
  etiqueta = VALUES(etiqueta),
  descripcion = VALUES(descripcion),
  orden = VALUES(orden);

INSERT INTO valores_variable (variable_ejercicio_id, valor, activo, orden)
SELECT DISTINCT ve.id, s.v, 1, 10
FROM tp5_ej01_seed s
INNER JOIN variables_ejercicio ve ON ve.ejercicio_id = @ej01 AND ve.nombre = 'V'
ON DUPLICATE KEY UPDATE activo = VALUES(activo);

INSERT INTO valores_variable (variable_ejercicio_id, valor, activo, orden)
SELECT DISTINCT ve.id, s.r, 1, 10
FROM tp5_ej01_seed s
INNER JOIN variables_ejercicio ve ON ve.ejercicio_id = @ej01 AND ve.nombre = 'R'
ON DUPLICATE KEY UPDATE activo = VALUES(activo);

INSERT INTO combinaciones_ejercicio (ejercicio_id, codigo_hash, respuesta_numero, respuesta_texto, usos, activa)
SELECT @ej01,
       SHA2(CONCAT('tp5-ej01-corriente-circuitos:n', s.n), 256),
       s.v / s.r,
       CONCAT(CAST(ROUND(s.v / s.r, 6) AS CHAR), ' A'),
       0,
       1
FROM tp5_ej01_seed s
ON DUPLICATE KEY UPDATE
  respuesta_numero = VALUES(respuesta_numero),
  respuesta_texto = VALUES(respuesta_texto),
  activa = VALUES(activa);

INSERT INTO combinacion_valores (combinacion_ejercicio_id, variable_ejercicio_id, valor_variable_id, valor)
SELECT ce.id, ve.id, vv.id, s.v
FROM tp5_ej01_seed s
INNER JOIN combinaciones_ejercicio ce ON ce.ejercicio_id = @ej01 AND ce.codigo_hash = SHA2(CONCAT('tp5-ej01-corriente-circuitos:n', s.n), 256)
INNER JOIN variables_ejercicio ve ON ve.ejercicio_id = @ej01 AND ve.nombre = 'V'
INNER JOIN valores_variable vv ON vv.variable_ejercicio_id = ve.id AND vv.valor = s.v
ON DUPLICATE KEY UPDATE
  valor_variable_id = VALUES(valor_variable_id),
  valor = VALUES(valor);

INSERT INTO combinacion_valores (combinacion_ejercicio_id, variable_ejercicio_id, valor_variable_id, valor)
SELECT ce.id, ve.id, vv.id, s.r
FROM tp5_ej01_seed s
INNER JOIN combinaciones_ejercicio ce ON ce.ejercicio_id = @ej01 AND ce.codigo_hash = SHA2(CONCAT('tp5-ej01-corriente-circuitos:n', s.n), 256)
INNER JOIN variables_ejercicio ve ON ve.ejercicio_id = @ej01 AND ve.nombre = 'R'
INNER JOIN valores_variable vv ON vv.variable_ejercicio_id = ve.id AND vv.valor = s.r
ON DUPLICATE KEY UPDATE
  valor_variable_id = VALUES(valor_variable_id),
  valor = VALUES(valor);

DROP TEMPORARY TABLE tp5_ej01_seed;

COMMIT;
