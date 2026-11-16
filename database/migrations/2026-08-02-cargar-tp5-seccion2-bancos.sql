USE electrodesafio;

START TRANSACTION;

INSERT INTO unidades (magnitud_id, nombre, simbolo, factor_base) VALUES
  (1, 'kilohm', 'kohm', 1000),
  (1, 'megaohm', 'Mohm', 1000000),
  (3, 'miliampere', 'mA', 0.001),
  (3, 'microampere', 'uA', 0.000001)
ON DUPLICATE KEY UPDATE
  nombre = VALUES(nombre),
  factor_base = VALUES(factor_base);

SET @tp5 := (SELECT id FROM trabajos_practicos WHERE codigo = 'tp5-ley-ohm-2026' LIMIT 1);
SET @sec2 := (SELECT id FROM secciones_tp WHERE trabajo_practico_id = @tp5 AND orden = 20 LIMIT 1);
SET @act2 := (SELECT id FROM actividades WHERE seccion_tp_id = @sec2 AND titulo = 'TP5 - Seccion 2' LIMIT 1);
SET @u_v := (SELECT id FROM unidades WHERE magnitud_id = 2 AND simbolo = 'V' LIMIT 1);
SET @u_kohm := (SELECT id FROM unidades WHERE magnitud_id = 1 AND simbolo = 'kohm' LIMIT 1);
SET @u_mohm := (SELECT id FROM unidades WHERE magnitud_id = 1 AND simbolo = 'Mohm' LIMIT 1);
SET @u_ma := (SELECT id FROM unidades WHERE magnitud_id = 3 AND simbolo = 'mA' LIMIT 1);
SET @u_ua := (SELECT id FROM unidades WHERE magnitud_id = 3 AND simbolo = 'uA' LIMIT 1);

UPDATE secciones_tp
SET titulo = 'Seccion 2 - Ley de Ohm con unidades',
    descripcion = 'Ejercicios con kOhm, MOhm, mA y microamperios.'
WHERE id = @sec2;

UPDATE actividades
SET titulo = 'TP5 - Seccion 2',
    descripcion = 'Ley de Ohm con conversion de unidades.',
    puntos = 10,
    estado = 'Disponible',
    visible_alumno = 1,
    acceso_habilitado = 1,
    puntaje_habilitado = 0
WHERE id = @act2;

INSERT INTO bancos_valores_seccion (seccion_tp_id, magnitud_id, unidad_id, nombre, codigo, descripcion, orden, activo) VALUES
  (@sec2, 2, @u_v, 'Tension seccion 2', 'V_S2', 'Valores de tension en voltios para la seccion 2.', 10, 1),
  (@sec2, 1, @u_kohm, 'Resistencia en kiloohmios', 'R_KOHM_S2', 'Valores de resistencia en kiloohmios.', 20, 1),
  (@sec2, 1, @u_mohm, 'Resistencia en megaohmios', 'R_MOHM_S2', 'Valores de resistencia en megaohmios.', 30, 1),
  (@sec2, 3, @u_ma, 'Corriente en miliamperios', 'I_MA_S2', 'Valores de corriente en miliamperios.', 40, 1),
  (@sec2, 3, @u_ua, 'Corriente en microamperios', 'I_UA_S2', 'Valores de corriente en microamperios.', 50, 1)
ON DUPLICATE KEY UPDATE
  magnitud_id = VALUES(magnitud_id),
  unidad_id = VALUES(unidad_id),
  nombre = VALUES(nombre),
  descripcion = VALUES(descripcion),
  orden = VALUES(orden),
  activo = VALUES(activo);

SET @banco_v := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec2 AND codigo = 'V_S2' LIMIT 1);
SET @banco_r_kohm := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec2 AND codigo = 'R_KOHM_S2' LIMIT 1);
SET @banco_r_mohm := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec2 AND codigo = 'R_MOHM_S2' LIMIT 1);
SET @banco_i_ma := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec2 AND codigo = 'I_MA_S2' LIMIT 1);
SET @banco_i_ua := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec2 AND codigo = 'I_UA_S2' LIMIT 1);

INSERT INTO valores_banco_seccion (banco_valores_seccion_id, indice, valor, etiqueta, activo) VALUES
  (@banco_v, 1, 3, '3 V', 1),
  (@banco_v, 2, 6, '6 V', 1),
  (@banco_v, 3, 9, '9 V', 1),
  (@banco_v, 4, 12, '12 V', 1),
  (@banco_v, 5, 15, '15 V', 1),
  (@banco_v, 6, 18, '18 V', 1),
  (@banco_v, 7, 24, '24 V', 1),
  (@banco_v, 8, 30, '30 V', 1),
  (@banco_r_kohm, 1, 0.5, '0,5 kohm', 1),
  (@banco_r_kohm, 2, 1, '1 kohm', 1),
  (@banco_r_kohm, 3, 1.5, '1,5 kohm', 1),
  (@banco_r_kohm, 4, 2, '2 kohm', 1),
  (@banco_r_kohm, 5, 2.5, '2,5 kohm', 1),
  (@banco_r_kohm, 6, 3, '3 kohm', 1),
  (@banco_r_kohm, 7, 4, '4 kohm', 1),
  (@banco_r_kohm, 8, 5, '5 kohm', 1),
  (@banco_r_mohm, 1, 0.1, '0,1 Mohm', 1),
  (@banco_r_mohm, 2, 0.2, '0,2 Mohm', 1),
  (@banco_r_mohm, 3, 0.3, '0,3 Mohm', 1),
  (@banco_r_mohm, 4, 0.5, '0,5 Mohm', 1),
  (@banco_r_mohm, 5, 0.6, '0,6 Mohm', 1),
  (@banco_r_mohm, 6, 1, '1 Mohm', 1),
  (@banco_r_mohm, 7, 1.5, '1,5 Mohm', 1),
  (@banco_r_mohm, 8, 2, '2 Mohm', 1),
  (@banco_i_ma, 1, 0.5, '0,5 mA', 1),
  (@banco_i_ma, 2, 1, '1 mA', 1),
  (@banco_i_ma, 3, 1.5, '1,5 mA', 1),
  (@banco_i_ma, 4, 2, '2 mA', 1),
  (@banco_i_ma, 5, 2.5, '2,5 mA', 1),
  (@banco_i_ma, 6, 3, '3 mA', 1),
  (@banco_i_ma, 7, 4, '4 mA', 1),
  (@banco_i_ma, 8, 5, '5 mA', 1),
  (@banco_i_ua, 1, 5, '5 uA', 1),
  (@banco_i_ua, 2, 10, '10 uA', 1),
  (@banco_i_ua, 3, 15, '15 uA', 1),
  (@banco_i_ua, 4, 20, '20 uA', 1),
  (@banco_i_ua, 5, 25, '25 uA', 1),
  (@banco_i_ua, 6, 30, '30 uA', 1),
  (@banco_i_ua, 7, 40, '40 uA', 1),
  (@banco_i_ua, 8, 50, '50 uA', 1)
ON DUPLICATE KEY UPDATE
  valor = VALUES(valor),
  etiqueta = VALUES(etiqueta),
  activo = VALUES(activo);

INSERT INTO ejercicios (actividad_id, seccion_tp_id, codigo, consigna, explicacion, formula_respuesta, tolerancia, orden, activo) VALUES
  (@act2, @sec2, 'tp5-s2-ej01-corriente-v-rkohm', 'Una resistencia {R_kohm} se conecta a una fuente de tension {V}. Calcule la corriente que circula y exprese el resultado en miliamperios.', 'Convierta la resistencia a ohmios y aplique I = V / R.', 'V / R', 0.05, 10, 1),
  (@act2, @sec2, 'tp5-s2-ej02-corriente-v-rmohm', 'Una resistencia {R_Mohm} se conecta a una fuente de tension {V}. Determine la corriente y exprese el resultado en microamperios.', 'Convierta la resistencia a ohmios y aplique I = V / R.', 'V / R', 0.05, 20, 1),
  (@act2, @sec2, 'tp5-s2-ej03-tension-rkohm-ima', 'Por una resistencia {R_kohm} circula una corriente {I_mA} expresada en miliamperios. Determine la tension aplicada y exprese el resultado en voltios.', 'Convierta la resistencia y la corriente a unidades base y aplique V = I x R.', 'I * R', 0.05, 30, 1),
  (@act2, @sec2, 'tp5-s2-ej04-tension-rmohm-iua', 'Una resistencia {R_Mohm} es atravesada por una corriente {I_uA} expresada en microamperios. Calcule la tension entre sus extremos.', 'Convierta la resistencia y la corriente a unidades base y aplique V = I x R.', 'I * R', 0.05, 40, 1),
  (@act2, @sec2, 'tp5-s2-ej05-resistencia-v-ima', 'En un circuito se aplica una tension {V} y se mide una corriente {I_mA} expresada en miliamperios. Determine la resistencia y exprese el resultado en kiloohmios.', 'Convierta la corriente a amperios y aplique R = V / I.', 'V / I', 0.05, 50, 1),
  (@act2, @sec2, 'tp5-s2-ej06-resistencia-v-iua', 'Una fuente {V} produce una corriente {I_uA} expresada en microamperios. Calcule la resistencia del circuito y exprese el resultado en megaohmios.', 'Convierta la corriente a amperios y aplique R = V / I.', 'V / I', 0.05, 60, 1)
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
    'tp5-s2-ej01-corriente-v-rkohm',
    'tp5-s2-ej02-corriente-v-rmohm',
    'tp5-s2-ej03-tension-rkohm-ima',
    'tp5-s2-ej04-tension-rmohm-iua',
    'tp5-s2-ej05-resistencia-v-ima',
    'tp5-s2-ej06-resistencia-v-iua'
  );

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, 2, @u_v, @banco_v, 'V', 'V', 'Tension asignada desde banco de la seccion 2.', 10
FROM ejercicios e
WHERE e.codigo IN ('tp5-s2-ej01-corriente-v-rkohm', 'tp5-s2-ej02-corriente-v-rmohm', 'tp5-s2-ej05-resistencia-v-ima', 'tp5-s2-ej06-resistencia-v-iua')
ON DUPLICATE KEY UPDATE magnitud_id=VALUES(magnitud_id), unidad_id=VALUES(unidad_id), banco_valores_seccion_id=VALUES(banco_valores_seccion_id), etiqueta=VALUES(etiqueta), descripcion=VALUES(descripcion), orden=VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, 1, @u_kohm, @banco_r_kohm, 'R_kohm', 'R_kohm', 'Resistencia en kiloohmios asignada desde banco de la seccion 2.', 20
FROM ejercicios e
WHERE e.codigo IN ('tp5-s2-ej01-corriente-v-rkohm', 'tp5-s2-ej03-tension-rkohm-ima')
ON DUPLICATE KEY UPDATE magnitud_id=VALUES(magnitud_id), unidad_id=VALUES(unidad_id), banco_valores_seccion_id=VALUES(banco_valores_seccion_id), etiqueta=VALUES(etiqueta), descripcion=VALUES(descripcion), orden=VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, 1, @u_mohm, @banco_r_mohm, 'R_Mohm', 'R_Mohm', 'Resistencia en megaohmios asignada desde banco de la seccion 2.', 20
FROM ejercicios e
WHERE e.codigo IN ('tp5-s2-ej02-corriente-v-rmohm', 'tp5-s2-ej04-tension-rmohm-iua')
ON DUPLICATE KEY UPDATE magnitud_id=VALUES(magnitud_id), unidad_id=VALUES(unidad_id), banco_valores_seccion_id=VALUES(banco_valores_seccion_id), etiqueta=VALUES(etiqueta), descripcion=VALUES(descripcion), orden=VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, 3, @u_ma, @banco_i_ma, 'I_mA', 'I_mA', 'Corriente en miliamperios asignada desde banco de la seccion 2.', 30
FROM ejercicios e
WHERE e.codigo IN ('tp5-s2-ej03-tension-rkohm-ima', 'tp5-s2-ej05-resistencia-v-ima')
ON DUPLICATE KEY UPDATE magnitud_id=VALUES(magnitud_id), unidad_id=VALUES(unidad_id), banco_valores_seccion_id=VALUES(banco_valores_seccion_id), etiqueta=VALUES(etiqueta), descripcion=VALUES(descripcion), orden=VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, 3, @u_ua, @banco_i_ua, 'I_uA', 'I_uA', 'Corriente en microamperios asignada desde banco de la seccion 2.', 30
FROM ejercicios e
WHERE e.codigo IN ('tp5-s2-ej04-tension-rmohm-iua', 'tp5-s2-ej06-resistencia-v-iua')
ON DUPLICATE KEY UPDATE magnitud_id=VALUES(magnitud_id), unidad_id=VALUES(unidad_id), banco_valores_seccion_id=VALUES(banco_valores_seccion_id), etiqueta=VALUES(etiqueta), descripcion=VALUES(descripcion), orden=VALUES(orden);

UPDATE combinaciones_ejercicio ce
INNER JOIN ejercicios e ON e.id = ce.ejercicio_id
SET ce.activa = 0
WHERE e.actividad_id = @act2;

COMMIT;
