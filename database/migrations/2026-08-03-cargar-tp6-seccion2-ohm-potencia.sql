USE electrodesafio;
SET NAMES utf8mb4;

START TRANSACTION;

SET @tp6 := (SELECT id FROM trabajos_practicos WHERE codigo = 'tp6-energia-potencia-2026' LIMIT 1);
SET @sec2 := (SELECT id FROM secciones_tp WHERE trabajo_practico_id = @tp6 AND orden = 20 LIMIT 1);
SET @tema := (SELECT tema_id FROM trabajos_practicos WHERE id = @tp6 LIMIT 1);
SET @contenedor := (SELECT id FROM contenedores_actividad WHERE tema_id = @tema AND nombre = 'TP 6' LIMIT 1);

SET @mag_v := (SELECT id FROM magnitudes WHERE simbolo = 'V' LIMIT 1);
SET @mag_i := (SELECT id FROM magnitudes WHERE simbolo = 'I' LIMIT 1);
SET @mag_r := (SELECT id FROM magnitudes WHERE simbolo = 'R' LIMIT 1);
SET @mag_p := (SELECT id FROM magnitudes WHERE simbolo = 'P' LIMIT 1);

SET @u_v := (SELECT id FROM unidades WHERE magnitud_id = @mag_v AND simbolo = 'V' LIMIT 1);
SET @u_a := (SELECT id FROM unidades WHERE magnitud_id = @mag_i AND simbolo = 'A' LIMIT 1);
SET @u_ohm := (SELECT id FROM unidades WHERE magnitud_id = @mag_r AND simbolo = 'ohm' LIMIT 1);
SET @u_w := (SELECT id FROM unidades WHERE magnitud_id = @mag_p AND simbolo = 'W' LIMIT 1);

UPDATE secciones_tp
SET titulo = 'Seccion 2 - Ley de Ohm y potencia electrica',
    descripcion = 'Relacion entre tension, corriente, resistencia y potencia.'
WHERE id = @sec2;

INSERT INTO actividades (contenedor_id, seccion_tp_id, titulo, descripcion, nivel, puntos, estado, visible_alumno, acceso_habilitado, puntaje_habilitado, icono, orden)
SELECT @contenedor, @sec2, 'TP6 - Seccion 2', 'Ley de Ohm aplicada a potencia electrica.', 'Intermedio', 10, 'Disponible', 1, 1, 0, 'W', 50
WHERE NOT EXISTS (
  SELECT 1 FROM actividades WHERE seccion_tp_id = @sec2 AND titulo = 'TP6 - Seccion 2'
);

SET @act2 := (SELECT id FROM actividades WHERE seccion_tp_id = @sec2 AND titulo = 'TP6 - Seccion 2' LIMIT 1);

UPDATE actividades
SET contenedor_id = @contenedor,
    descripcion = 'Ley de Ohm aplicada a potencia electrica.',
    nivel = 'Intermedio',
    puntos = 10,
    estado = 'Disponible',
    visible_alumno = 1,
    acceso_habilitado = 1,
    puntaje_habilitado = 0,
    icono = 'W',
    orden = 50
WHERE id = @act2;

INSERT INTO bancos_valores_seccion (seccion_tp_id, magnitud_id, unidad_id, nombre, codigo, descripcion, orden, activo) VALUES
  (@sec2, @mag_v, @u_v, 'Tension TP6 seccion 2', 'V_TP6_S2', 'Tensiones en voltios para Ley de Ohm y potencia.', 10, 1),
  (@sec2, @mag_i, @u_a, 'Corriente TP6 seccion 2', 'I_A_TP6_S2', 'Corrientes en amperios.', 20, 1),
  (@sec2, @mag_r, @u_ohm, 'Resistencia TP6 seccion 2', 'R_OHM_TP6_S2', 'Resistencias en ohmios.', 30, 1),
  (@sec2, @mag_p, @u_w, 'Potencia TP6 seccion 2', 'P_W_TP6_S2', 'Potencias en watts.', 40, 1)
ON DUPLICATE KEY UPDATE
  magnitud_id = VALUES(magnitud_id),
  unidad_id = VALUES(unidad_id),
  nombre = VALUES(nombre),
  descripcion = VALUES(descripcion),
  orden = VALUES(orden),
  activo = VALUES(activo);

SET @b_v := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec2 AND codigo = 'V_TP6_S2' LIMIT 1);
SET @b_i := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec2 AND codigo = 'I_A_TP6_S2' LIMIT 1);
SET @b_r := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec2 AND codigo = 'R_OHM_TP6_S2' LIMIT 1);
SET @b_p := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec2 AND codigo = 'P_W_TP6_S2' LIMIT 1);

INSERT INTO valores_banco_seccion (banco_valores_seccion_id, indice, valor, etiqueta, activo) VALUES
  (@b_v, 1, 5, '5 V', 1),
  (@b_v, 2, 6, '6 V', 1),
  (@b_v, 3, 9, '9 V', 1),
  (@b_v, 4, 12, '12 V', 1),
  (@b_v, 5, 15, '15 V', 1),
  (@b_v, 6, 18, '18 V', 1),
  (@b_v, 7, 24, '24 V', 1),
  (@b_v, 8, 30, '30 V', 1),
  (@b_i, 1, 0.10, '0,10 A', 1),
  (@b_i, 2, 0.20, '0,20 A', 1),
  (@b_i, 3, 0.25, '0,25 A', 1),
  (@b_i, 4, 0.30, '0,30 A', 1),
  (@b_i, 5, 0.40, '0,40 A', 1),
  (@b_i, 6, 0.50, '0,50 A', 1),
  (@b_i, 7, 0.60, '0,60 A', 1),
  (@b_i, 8, 0.75, '0,75 A', 1),
  (@b_r, 1, 10, '10 ohm', 1),
  (@b_r, 2, 20, '20 ohm', 1),
  (@b_r, 3, 30, '30 ohm', 1),
  (@b_r, 4, 40, '40 ohm', 1),
  (@b_r, 5, 50, '50 ohm', 1),
  (@b_r, 6, 60, '60 ohm', 1),
  (@b_r, 7, 80, '80 ohm', 1),
  (@b_r, 8, 100, '100 ohm', 1),
  (@b_p, 1, 5, '5 W', 1),
  (@b_p, 2, 10, '10 W', 1),
  (@b_p, 3, 12, '12 W', 1),
  (@b_p, 4, 18, '18 W', 1),
  (@b_p, 5, 24, '24 W', 1),
  (@b_p, 6, 30, '30 W', 1),
  (@b_p, 7, 45, '45 W', 1),
  (@b_p, 8, 60, '60 W', 1)
ON DUPLICATE KEY UPDATE
  valor = VALUES(valor),
  etiqueta = VALUES(etiqueta),
  activo = VALUES(activo);

INSERT INTO ejercicios (actividad_id, seccion_tp_id, codigo, consigna, explicacion, formula_respuesta, tolerancia, orden, activo) VALUES
  (@act2, @sec2, 'tp6-s2-ej01-potencia-v-i', 'Un dispositivo funciona con una tension {V} y absorbe una corriente {I_A}. Determine la potencia electrica consumida.', 'Aplique P = V x I.', 'V * I', 0.05, 10, 1),
  (@act2, @sec2, 'tp6-s2-ej02-tension-r-i', 'Por una resistencia {R_ohm} circula una corriente {I_A}. Determine la tension entre sus extremos.', 'Aplique V = I x R.', 'I * R', 0.05, 20, 1),
  (@act2, @sec2, 'tp6-s2-ej03-corriente-v-r', 'Una resistencia {R_ohm} se conecta a una tension {V}. Determine la corriente que circula.', 'Aplique I = V / R.', 'V / R', 0.05, 30, 1),
  (@act2, @sec2, 'tp6-s2-ej04-resistencia-v-i', 'Una carga conectada a {V} absorbe una corriente {I_A}. Determine su resistencia electrica.', 'Aplique R = V / I.', 'V / I', 0.05, 40, 1),
  (@act2, @sec2, 'tp6-s2-ej05-potencia-i2r', 'Una resistencia {R_ohm} es recorrida por una corriente {I_A}. Calcule la potencia disipada.', 'Aplique P = I x I x R.', 'I * I * R', 0.05, 50, 1),
  (@act2, @sec2, 'tp6-s2-ej06-potencia-v2r', 'Una resistencia {R_ohm} tiene aplicada una tension {V}. Calcule la potencia que disipa.', 'Aplique P = V x V / R.', 'V * V / R', 0.05, 60, 1),
  (@act2, @sec2, 'tp6-s2-ej07-tension-p-i', 'Una carga consume {P_W} mientras circula una corriente {I_A}. Determine la tension aplicada.', 'Aplique V = P / I.', 'P / I', 0.05, 70, 1),
  (@act2, @sec2, 'tp6-s2-ej08-corriente-p-v', 'Un equipo consume {P_W} cuando se conecta a una tension {V}. Determine la corriente absorbida.', 'Aplique I = P / V.', 'P / V', 0.05, 80, 1)
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
WHERE actividad_id = @act2
  AND codigo NOT IN (
    'tp6-s2-ej01-potencia-v-i',
    'tp6-s2-ej02-tension-r-i',
    'tp6-s2-ej03-corriente-v-r',
    'tp6-s2-ej04-resistencia-v-i',
    'tp6-s2-ej05-potencia-i2r',
    'tp6-s2-ej06-potencia-v2r',
    'tp6-s2-ej07-tension-p-i',
    'tp6-s2-ej08-corriente-p-v'
  );

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_v, @u_v, @b_v, 'V', 'V', 'Tension asignada desde banco de TP6 seccion 2.', 10
FROM ejercicios e
WHERE e.codigo IN (
  'tp6-s2-ej01-potencia-v-i',
  'tp6-s2-ej03-corriente-v-r',
  'tp6-s2-ej04-resistencia-v-i',
  'tp6-s2-ej06-potencia-v2r',
  'tp6-s2-ej08-corriente-p-v'
)
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_i, @u_a, @b_i, 'I_A', 'I_A', 'Corriente asignada desde banco de TP6 seccion 2.', 20
FROM ejercicios e
WHERE e.codigo IN (
  'tp6-s2-ej01-potencia-v-i',
  'tp6-s2-ej02-tension-r-i',
  'tp6-s2-ej04-resistencia-v-i',
  'tp6-s2-ej05-potencia-i2r',
  'tp6-s2-ej07-tension-p-i'
)
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_r, @u_ohm, @b_r, 'R_ohm', 'R_ohm', 'Resistencia asignada desde banco de TP6 seccion 2.', 10
FROM ejercicios e
WHERE e.codigo IN (
  'tp6-s2-ej02-tension-r-i',
  'tp6-s2-ej03-corriente-v-r',
  'tp6-s2-ej05-potencia-i2r',
  'tp6-s2-ej06-potencia-v2r'
)
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_p, @u_w, @b_p, 'P_W', 'P_W', 'Potencia asignada desde banco de TP6 seccion 2.', 10
FROM ejercicios e
WHERE e.codigo IN (
  'tp6-s2-ej07-tension-p-i',
  'tp6-s2-ej08-corriente-p-v'
)
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

UPDATE combinaciones_ejercicio ce
INNER JOIN ejercicios e ON e.id = ce.ejercicio_id
SET ce.activa = 0
WHERE e.actividad_id = @act2;

COMMIT;
