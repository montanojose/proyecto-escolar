USE electrodesafio;

START TRANSACTION;

SET @tp5 := (SELECT id FROM trabajos_practicos WHERE codigo = 'tp5-ley-ohm-2026' LIMIT 1);
SET @sec1 := (SELECT id FROM secciones_tp WHERE trabajo_practico_id = @tp5 AND orden = 10 LIMIT 1);
SET @act1 := (SELECT id FROM actividades WHERE seccion_tp_id = @sec1 AND titulo = 'TP5 - Seccion 1' LIMIT 1);

UPDATE secciones_tp
SET titulo = 'Seccion 1 - Aplicacion directa de la Ley de Ohm',
    descripcion = 'Ejercicios directos con V, R e I usando bancos de valores de la seccion.'
WHERE id = @sec1;

UPDATE actividades
SET titulo = 'TP5 - Seccion 1',
    descripcion = 'Aplicacion directa de la Ley de Ohm con tension, resistencia y corriente.',
    puntos = 10,
    estado = 'Disponible',
    visible_alumno = 1,
    acceso_habilitado = 1,
    puntaje_habilitado = 0
WHERE id = @act1;

INSERT INTO bancos_valores_seccion (seccion_tp_id, magnitud_id, unidad_id, nombre, codigo, descripcion, orden, activo) VALUES
  (@sec1, 2, 2, 'Tension directa', 'V_S1', 'Valores de tension en voltios para la seccion 1.', 10, 1),
  (@sec1, 1, 1, 'Resistencia directa', 'R_S1', 'Valores de resistencia en ohmios para la seccion 1.', 20, 1),
  (@sec1, 3, 3, 'Corriente directa', 'I_S1', 'Valores de corriente en amperios para la seccion 1.', 30, 1)
ON DUPLICATE KEY UPDATE
  magnitud_id = VALUES(magnitud_id),
  unidad_id = VALUES(unidad_id),
  nombre = VALUES(nombre),
  descripcion = VALUES(descripcion),
  orden = VALUES(orden),
  activo = VALUES(activo);

SET @banco_v := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec1 AND codigo = 'V_S1' LIMIT 1);
SET @banco_r := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec1 AND codigo = 'R_S1' LIMIT 1);
SET @banco_i := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec1 AND codigo = 'I_S1' LIMIT 1);

INSERT INTO valores_banco_seccion (banco_valores_seccion_id, indice, valor, etiqueta, activo) VALUES
  (@banco_v, 1, 3, '3 V', 1),
  (@banco_v, 2, 6, '6 V', 1),
  (@banco_v, 3, 9, '9 V', 1),
  (@banco_v, 4, 12, '12 V', 1),
  (@banco_v, 5, 15, '15 V', 1),
  (@banco_v, 6, 18, '18 V', 1),
  (@banco_v, 7, 24, '24 V', 1),
  (@banco_v, 8, 30, '30 V', 1),
  (@banco_r, 1, 10, '10 ohm', 1),
  (@banco_r, 2, 20, '20 ohm', 1),
  (@banco_r, 3, 30, '30 ohm', 1),
  (@banco_r, 4, 40, '40 ohm', 1),
  (@banco_r, 5, 50, '50 ohm', 1),
  (@banco_r, 6, 60, '60 ohm', 1),
  (@banco_r, 7, 100, '100 ohm', 1),
  (@banco_r, 8, 120, '120 ohm', 1),
  (@banco_i, 1, 0.05, '0,05 A', 1),
  (@banco_i, 2, 0.10, '0,10 A', 1),
  (@banco_i, 3, 0.15, '0,15 A', 1),
  (@banco_i, 4, 0.20, '0,20 A', 1),
  (@banco_i, 5, 0.25, '0,25 A', 1),
  (@banco_i, 6, 0.30, '0,30 A', 1),
  (@banco_i, 7, 0.40, '0,40 A', 1),
  (@banco_i, 8, 0.50, '0,50 A', 1)
ON DUPLICATE KEY UPDATE
  valor = VALUES(valor),
  etiqueta = VALUES(etiqueta),
  activo = VALUES(activo);

INSERT INTO ejercicios (actividad_id, seccion_tp_id, codigo, consigna, explicacion, formula_respuesta, tolerancia, orden, activo) VALUES
  (@act1, @sec1, 'tp5-s1-ej01-corriente-vr', 'Observe un circuito simple alimentado con una tension {V} y conectado a una resistencia {R}. Determine la corriente que circula por el circuito.', 'Aplicacion directa de I = V / R.', 'V / R', 0.05, 10, 1),
  (@act1, @sec1, 'tp5-s1-ej02-corriente-vr', 'Una resistencia de valor {R} se conecta a una fuente de tension {V}. Calcule la corriente que atraviesa la resistencia.', 'Aplicacion directa de I = V / R.', 'V / R', 0.05, 20, 1),
  (@act1, @sec1, 'tp5-s1-ej03-tension-ri', 'Por una resistencia {R} circula una corriente {I}. Determine la tension aplicada entre sus extremos.', 'Aplicacion directa de V = I x R.', 'I * R', 0.05, 30, 1),
  (@act1, @sec1, 'tp5-s1-ej04-tension-ri', 'Una carga resistiva de valor {R} es atravesada por una corriente {I}. Calcule la tension entregada por la fuente.', 'Aplicacion directa de V = I x R.', 'I * R', 0.05, 40, 1),
  (@act1, @sec1, 'tp5-s1-ej05-resistencia-vi', 'En un circuito se mide una tension {V} y una corriente {I}. Determine el valor de la resistencia conectada.', 'Aplicacion directa de R = V / I.', 'V / I', 0.05, 50, 1),
  (@act1, @sec1, 'tp5-s1-ej06-resistencia-vi', 'Una fuente aplica una tension {V} sobre un circuito por el cual circula una corriente {I}. Calcule la resistencia del circuito.', 'Aplicacion directa de R = V / I.', 'V / I', 0.05, 60, 1),
  (@act1, @sec1, 'tp5-s1-ej07-amperimetro-vr', 'Un amperimetro conectado en serie con una resistencia {R} registra la corriente producida por una fuente {V}. Determine que valor deberia indicar el instrumento.', 'El amperimetro mide corriente. Use I = V / R.', 'V / R', 0.05, 70, 1),
  (@act1, @sec1, 'tp5-s1-ej08-voltimetro-ri', 'Por una resistencia {R} circula una corriente {I}. Determine que tension deberia indicar un voltimetro conectado en paralelo con la resistencia.', 'El voltimetro mide tension. Use V = I x R.', 'I * R', 0.05, 80, 1)
ON DUPLICATE KEY UPDATE
  actividad_id = VALUES(actividad_id),
  seccion_tp_id = VALUES(seccion_tp_id),
  consigna = VALUES(consigna),
  explicacion = VALUES(explicacion),
  formula_respuesta = VALUES(formula_respuesta),
  tolerancia = VALUES(tolerancia),
  orden = VALUES(orden),
  activo = VALUES(activo);

UPDATE ejercicios
SET activo = 0
WHERE actividad_id = @act1
  AND codigo NOT IN (
    'tp5-s1-ej01-corriente-vr',
    'tp5-s1-ej02-corriente-vr',
    'tp5-s1-ej03-tension-ri',
    'tp5-s1-ej04-tension-ri',
    'tp5-s1-ej05-resistencia-vi',
    'tp5-s1-ej06-resistencia-vi',
    'tp5-s1-ej07-amperimetro-vr',
    'tp5-s1-ej08-voltimetro-ri'
  );

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, 2, 2, @banco_v, 'V', 'V', 'Tension asignada desde banco de la seccion 1.', 10
FROM ejercicios e
WHERE e.codigo IN ('tp5-s1-ej01-corriente-vr', 'tp5-s1-ej02-corriente-vr', 'tp5-s1-ej05-resistencia-vi', 'tp5-s1-ej06-resistencia-vi', 'tp5-s1-ej07-amperimetro-vr')
ON DUPLICATE KEY UPDATE
  magnitud_id = VALUES(magnitud_id),
  unidad_id = VALUES(unidad_id),
  banco_valores_seccion_id = VALUES(banco_valores_seccion_id),
  etiqueta = VALUES(etiqueta),
  descripcion = VALUES(descripcion),
  orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, 1, 1, @banco_r, 'R', 'R', 'Resistencia asignada desde banco de la seccion 1.', 20
FROM ejercicios e
WHERE e.codigo IN ('tp5-s1-ej01-corriente-vr', 'tp5-s1-ej02-corriente-vr', 'tp5-s1-ej03-tension-ri', 'tp5-s1-ej04-tension-ri', 'tp5-s1-ej07-amperimetro-vr', 'tp5-s1-ej08-voltimetro-ri')
ON DUPLICATE KEY UPDATE
  magnitud_id = VALUES(magnitud_id),
  unidad_id = VALUES(unidad_id),
  banco_valores_seccion_id = VALUES(banco_valores_seccion_id),
  etiqueta = VALUES(etiqueta),
  descripcion = VALUES(descripcion),
  orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, 3, 3, @banco_i, 'I', 'I', 'Corriente asignada desde banco de la seccion 1.', 30
FROM ejercicios e
WHERE e.codigo IN ('tp5-s1-ej03-tension-ri', 'tp5-s1-ej04-tension-ri', 'tp5-s1-ej05-resistencia-vi', 'tp5-s1-ej06-resistencia-vi', 'tp5-s1-ej08-voltimetro-ri')
ON DUPLICATE KEY UPDATE
  magnitud_id = VALUES(magnitud_id),
  unidad_id = VALUES(unidad_id),
  banco_valores_seccion_id = VALUES(banco_valores_seccion_id),
  etiqueta = VALUES(etiqueta),
  descripcion = VALUES(descripcion),
  orden = VALUES(orden);

UPDATE combinaciones_ejercicio ce
INNER JOIN ejercicios e ON e.id = ce.ejercicio_id
SET ce.activa = 0
WHERE e.actividad_id = @act1;

COMMIT;
