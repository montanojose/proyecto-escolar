USE electrodesafio;
SET NAMES utf8mb4;

START TRANSACTION;

SET @tp6 := (SELECT id FROM trabajos_practicos WHERE codigo = 'tp6-energia-potencia-2026' LIMIT 1);
SET @sec3 := (SELECT id FROM secciones_tp WHERE trabajo_practico_id = @tp6 AND orden = 30 LIMIT 1);
SET @tema := (SELECT tema_id FROM trabajos_practicos WHERE id = @tp6 LIMIT 1);
SET @contenedor := (SELECT id FROM contenedores_actividad WHERE tema_id = @tema AND nombre = 'TP 6' LIMIT 1);

SET @mag_v := (SELECT id FROM magnitudes WHERE simbolo = 'V' LIMIT 1);
SET @mag_i := (SELECT id FROM magnitudes WHERE simbolo = 'I' LIMIT 1);
SET @mag_r := (SELECT id FROM magnitudes WHERE simbolo = 'R' LIMIT 1);
SET @mag_p := (SELECT id FROM magnitudes WHERE simbolo = 'P' LIMIT 1);
SET @mag_e := (SELECT id FROM magnitudes WHERE simbolo = 'E' LIMIT 1);
SET @mag_t := (SELECT id FROM magnitudes WHERE simbolo = 't' LIMIT 1);
SET @mag_n := (SELECT id FROM magnitudes WHERE simbolo = 'N' LIMIT 1);

INSERT INTO unidades (magnitud_id, nombre, simbolo, factor_base) VALUES
  (@mag_n, 'dia', 'dia', 1),
  (@mag_t, 'hora por dia', 'h/dia', 1)
ON DUPLICATE KEY UPDATE
  nombre = VALUES(nombre),
  factor_base = VALUES(factor_base);

SET @u_v := (SELECT id FROM unidades WHERE magnitud_id = @mag_v AND simbolo = 'V' LIMIT 1);
SET @u_ma := (SELECT id FROM unidades WHERE magnitud_id = @mag_i AND simbolo = 'mA' LIMIT 1);
SET @u_kohm := (SELECT id FROM unidades WHERE magnitud_id = @mag_r AND simbolo = 'kohm' LIMIT 1);
SET @u_w := (SELECT id FROM unidades WHERE magnitud_id = @mag_p AND simbolo = 'W' LIMIT 1);
SET @u_kw := (SELECT id FROM unidades WHERE magnitud_id = @mag_p AND simbolo = 'kW' LIMIT 1);
SET @u_min := (SELECT id FROM unidades WHERE magnitud_id = @mag_t AND simbolo = 'min' LIMIT 1);
SET @u_h := (SELECT id FROM unidades WHERE magnitud_id = @mag_t AND simbolo = 'h' LIMIT 1);
SET @u_dia := (SELECT id FROM unidades WHERE magnitud_id = @mag_n AND simbolo = 'dia' LIMIT 1);
SET @u_kwh := (SELECT id FROM unidades WHERE magnitud_id = @mag_e AND simbolo = 'kWh' LIMIT 1);
SET @u_h_dia := (SELECT id FROM unidades WHERE magnitud_id = @mag_t AND simbolo = 'h/dia' LIMIT 1);

UPDATE secciones_tp
SET titulo = 'Seccion 3 - Aplicaciones integradoras',
    descripcion = 'Prefijos electricos, potencia, tiempo de funcionamiento, consumo energetico y costo.'
WHERE id = @sec3;

INSERT INTO actividades (contenedor_id, seccion_tp_id, titulo, descripcion, nivel, puntos, estado, visible_alumno, acceso_habilitado, puntaje_habilitado, icono, orden)
SELECT @contenedor, @sec3, 'TP6 - Seccion 3', 'Aplicaciones integradoras de energia, potencia y costo electrico.', 'Integrador', 10, 'Disponible', 1, 1, 0, '$', 60
WHERE NOT EXISTS (
  SELECT 1 FROM actividades WHERE seccion_tp_id = @sec3 AND titulo = 'TP6 - Seccion 3'
);

SET @act3 := (SELECT id FROM actividades WHERE seccion_tp_id = @sec3 AND titulo = 'TP6 - Seccion 3' LIMIT 1);

UPDATE actividades
SET contenedor_id = @contenedor,
    descripcion = 'Aplicaciones integradoras de energia, potencia y costo electrico.',
    nivel = 'Integrador',
    puntos = 10,
    estado = 'Disponible',
    visible_alumno = 1,
    acceso_habilitado = 1,
    puntaje_habilitado = 0,
    icono = '$',
    orden = 60
WHERE id = @act3;

INSERT INTO bancos_valores_seccion (seccion_tp_id, magnitud_id, unidad_id, nombre, codigo, descripcion, orden, activo) VALUES
  (@sec3, @mag_v, @u_v, 'Tension TP6 seccion 3', 'V_TP6_S3', 'Tensiones en voltios.', 10, 1),
  (@sec3, @mag_i, @u_ma, 'Corriente en mA TP6 seccion 3', 'I_MA_TP6_S3', 'Corrientes en miliamperios.', 20, 1),
  (@sec3, @mag_r, @u_kohm, 'Resistencia en kohm TP6 seccion 3', 'R_KOHM_TP6_S3', 'Resistencias en kiloohmios.', 30, 1),
  (@sec3, @mag_p, @u_w, 'Potencia en W TP6 seccion 3', 'P_W_TP6_S3', 'Potencias en watts.', 40, 1),
  (@sec3, @mag_t, @u_min, 'Tiempo en minutos TP6 seccion 3', 'T_MIN_TP6_S3', 'Tiempos en minutos.', 50, 1),
  (@sec3, @mag_p, @u_kw, 'Potencia en kW TP6 seccion 3', 'P_KW_TP6_S3', 'Potencias en kilowatts.', 60, 1),
  (@sec3, @mag_t, @u_h, 'Tiempo en horas TP6 seccion 3', 'T_H_TP6_S3', 'Tiempos en horas.', 70, 1),
  (@sec3, @mag_n, @u_dia, 'Dias TP6 seccion 3', 'DIAS_TP6_S3', 'Cantidad de dias.', 80, 1),
  (@sec3, @mag_e, @u_kwh, 'Energia en kWh TP6 seccion 3', 'E_KWH_TP6_S3', 'Energias en kWh.', 90, 1),
  (@sec3, @mag_p, @u_w, 'Potencia de lampara TP6 seccion 3', 'P_LAMPARA_W_TP6_S3', 'Potencias de lamparas en watts.', 100, 1),
  (@sec3, @mag_t, @u_h_dia, 'Horas por dia TP6 seccion 3', 'H_DIA_TP6_S3', 'Horas de uso por dia.', 110, 1)
ON DUPLICATE KEY UPDATE
  magnitud_id = VALUES(magnitud_id),
  unidad_id = VALUES(unidad_id),
  nombre = VALUES(nombre),
  descripcion = VALUES(descripcion),
  orden = VALUES(orden),
  activo = VALUES(activo);

SET @b_v := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec3 AND codigo = 'V_TP6_S3' LIMIT 1);
SET @b_i_ma := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec3 AND codigo = 'I_MA_TP6_S3' LIMIT 1);
SET @b_r_kohm := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec3 AND codigo = 'R_KOHM_TP6_S3' LIMIT 1);
SET @b_p_w := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec3 AND codigo = 'P_W_TP6_S3' LIMIT 1);
SET @b_t_min := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec3 AND codigo = 'T_MIN_TP6_S3' LIMIT 1);
SET @b_p_kw := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec3 AND codigo = 'P_KW_TP6_S3' LIMIT 1);
SET @b_t_h := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec3 AND codigo = 'T_H_TP6_S3' LIMIT 1);
SET @b_dias := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec3 AND codigo = 'DIAS_TP6_S3' LIMIT 1);
SET @b_e_kwh := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec3 AND codigo = 'E_KWH_TP6_S3' LIMIT 1);
SET @b_p_lampara := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec3 AND codigo = 'P_LAMPARA_W_TP6_S3' LIMIT 1);
SET @b_h_dia := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec3 AND codigo = 'H_DIA_TP6_S3' LIMIT 1);

INSERT INTO valores_banco_seccion (banco_valores_seccion_id, indice, valor, etiqueta, activo) VALUES
  (@b_v, 1, 5, '5 V', 1), (@b_v, 2, 9, '9 V', 1), (@b_v, 3, 12, '12 V', 1), (@b_v, 4, 15, '15 V', 1), (@b_v, 5, 18, '18 V', 1), (@b_v, 6, 24, '24 V', 1), (@b_v, 7, 30, '30 V', 1), (@b_v, 8, 48, '48 V', 1),
  (@b_i_ma, 1, 5, '5 mA', 1), (@b_i_ma, 2, 10, '10 mA', 1), (@b_i_ma, 3, 20, '20 mA', 1), (@b_i_ma, 4, 25, '25 mA', 1), (@b_i_ma, 5, 40, '40 mA', 1), (@b_i_ma, 6, 50, '50 mA', 1), (@b_i_ma, 7, 75, '75 mA', 1), (@b_i_ma, 8, 100, '100 mA', 1),
  (@b_r_kohm, 1, 0.10, '0,10 kohm', 1), (@b_r_kohm, 2, 0.22, '0,22 kohm', 1), (@b_r_kohm, 3, 0.33, '0,33 kohm', 1), (@b_r_kohm, 4, 0.47, '0,47 kohm', 1), (@b_r_kohm, 5, 0.68, '0,68 kohm', 1), (@b_r_kohm, 6, 1.00, '1 kohm', 1), (@b_r_kohm, 7, 1.50, '1,50 kohm', 1), (@b_r_kohm, 8, 2.20, '2,20 kohm', 1),
  (@b_p_w, 1, 25, '25 W', 1), (@b_p_w, 2, 40, '40 W', 1), (@b_p_w, 3, 60, '60 W', 1), (@b_p_w, 4, 75, '75 W', 1), (@b_p_w, 5, 100, '100 W', 1), (@b_p_w, 6, 150, '150 W', 1), (@b_p_w, 7, 250, '250 W', 1), (@b_p_w, 8, 300, '300 W', 1),
  (@b_t_min, 1, 2, '2 min', 1), (@b_t_min, 2, 5, '5 min', 1), (@b_t_min, 3, 10, '10 min', 1), (@b_t_min, 4, 15, '15 min', 1), (@b_t_min, 5, 20, '20 min', 1), (@b_t_min, 6, 30, '30 min', 1), (@b_t_min, 7, 45, '45 min', 1), (@b_t_min, 8, 60, '60 min', 1),
  (@b_p_kw, 1, 0.10, '0,10 kW', 1), (@b_p_kw, 2, 0.20, '0,20 kW', 1), (@b_p_kw, 3, 0.30, '0,30 kW', 1), (@b_p_kw, 4, 0.50, '0,50 kW', 1), (@b_p_kw, 5, 0.75, '0,75 kW', 1), (@b_p_kw, 6, 1.00, '1 kW', 1), (@b_p_kw, 7, 1.50, '1,50 kW', 1), (@b_p_kw, 8, 2.00, '2 kW', 1),
  (@b_t_h, 1, 0.5, '0,5 h', 1), (@b_t_h, 2, 1, '1 h', 1), (@b_t_h, 3, 2, '2 h', 1), (@b_t_h, 4, 3, '3 h', 1), (@b_t_h, 5, 4, '4 h', 1), (@b_t_h, 6, 6, '6 h', 1), (@b_t_h, 7, 8, '8 h', 1), (@b_t_h, 8, 12, '12 h', 1),
  (@b_dias, 1, 5, '5 dias', 1), (@b_dias, 2, 7, '7 dias', 1), (@b_dias, 3, 10, '10 dias', 1), (@b_dias, 4, 15, '15 dias', 1), (@b_dias, 5, 20, '20 dias', 1), (@b_dias, 6, 25, '25 dias', 1), (@b_dias, 7, 30, '30 dias', 1), (@b_dias, 8, 31, '31 dias', 1),
  (@b_e_kwh, 1, 30, '30 kWh', 1), (@b_e_kwh, 2, 60, '60 kWh', 1), (@b_e_kwh, 3, 90, '90 kWh', 1), (@b_e_kwh, 4, 120, '120 kWh', 1), (@b_e_kwh, 5, 150, '150 kWh', 1), (@b_e_kwh, 6, 240, '240 kWh', 1), (@b_e_kwh, 7, 300, '300 kWh', 1), (@b_e_kwh, 8, 450, '450 kWh', 1),
  (@b_p_lampara, 1, 5, '5 W', 1), (@b_p_lampara, 2, 7, '7 W', 1), (@b_p_lampara, 3, 9, '9 W', 1), (@b_p_lampara, 4, 10, '10 W', 1), (@b_p_lampara, 5, 12, '12 W', 1), (@b_p_lampara, 6, 15, '15 W', 1), (@b_p_lampara, 7, 18, '18 W', 1), (@b_p_lampara, 8, 20, '20 W', 1),
  (@b_h_dia, 1, 2, '2 h/dia', 1), (@b_h_dia, 2, 3, '3 h/dia', 1), (@b_h_dia, 3, 4, '4 h/dia', 1), (@b_h_dia, 4, 5, '5 h/dia', 1), (@b_h_dia, 5, 6, '6 h/dia', 1), (@b_h_dia, 6, 8, '8 h/dia', 1), (@b_h_dia, 7, 10, '10 h/dia', 1), (@b_h_dia, 8, 12, '12 h/dia', 1)
ON DUPLICATE KEY UPDATE valor = VALUES(valor), etiqueta = VALUES(etiqueta), activo = VALUES(activo);

INSERT INTO ejercicios (actividad_id, seccion_tp_id, codigo, consigna, explicacion, formula_respuesta, tolerancia, orden, activo) VALUES
  (@act3, @sec3, 'tp6-s3-ej01-potencia-v-ima', 'Un dispositivo funciona con una tension {V} y absorbe una corriente de {I_mA}. Determine la potencia consumida.', 'Convierta mA a A y aplique P = V x I.', 'V * I', 0.05, 10, 1),
  (@act3, @sec3, 'tp6-s3-ej02-potencia-ima-rkohm', 'Por una resistencia de {R_kohm} circula una corriente de {I_mA}. Calcule la potencia disipada.', 'Convierta unidades y aplique P = I x I x R.', 'I * I * R', 0.05, 20, 1),
  (@act3, @sec3, 'tp6-s3-ej03-potencia-v-rkohm', 'Una resistencia de {R_kohm} tiene aplicada una tension de {V}. Determine la potencia disipada.', 'Convierta kohm a ohm y aplique P = V x V / R.', 'V * V / R', 0.05, 30, 1),
  (@act3, @sec3, 'tp6-s3-ej04-energia-w-min', 'Un equipo de {P_W} funciona durante {t_min}. Determine la energia consumida.', 'Convierta minutos a segundos y aplique E = P x t.', 'P * T', 0.05, 40, 1),
  (@act3, @sec3, 'tp6-s3-ej05-energia-kw-h', 'Una maquina de {P_kW} funciona durante {t_h}. Determine la energia consumida.', 'Multiplique potencia por tiempo. Puede expresar el resultado en kWh.', 'P * T', 0.05, 50, 1),
  (@act3, @sec3, 'tp6-s3-ej06-energia-w-dias', 'Un artefacto de {P_W} permanece encendido continuamente durante {dias}. Determine la energia consumida.', 'Calcule el consumo en kWh usando P/1000 x 24 x dias.', 'P * D * 24 * 3600', 0.05, 60, 1),
  (@act3, @sec3, 'tp6-s3-ej07-promedio-kwh-dias', 'Durante {dias}, una instalacion consumio {E_kWh}. Determine su consumo diario promedio.', 'Divida la energia total por la cantidad de dias.', 'E / D', 0.05, 70, 1),
  (@act3, @sec3, 'tp6-s3-ej08-costo-lampara', 'Una lampara de {P_lampara_W} permanece encendida {h_dia} durante un mes de 30 dias. Si el precio de la energia es de $238 por kWh, determine cuanto dinero cuesta utilizar la lampara durante ese mes.', 'Calcule kWh = P/1000 x horas por dia x 30 y multiplique por 238.', 'P * H * 30 * 238 / 1000', 0.05, 80, 1)
ON DUPLICATE KEY UPDATE actividad_id = VALUES(actividad_id), seccion_tp_id = VALUES(seccion_tp_id), consigna = VALUES(consigna), explicacion = VALUES(explicacion), formula_respuesta = VALUES(formula_respuesta), tolerancia = VALUES(tolerancia), orden = VALUES(orden), activo = VALUES(activo);

UPDATE ejercicios
SET activo = 0
WHERE actividad_id = @act3
  AND codigo NOT IN (
    'tp6-s3-ej01-potencia-v-ima',
    'tp6-s3-ej02-potencia-ima-rkohm',
    'tp6-s3-ej03-potencia-v-rkohm',
    'tp6-s3-ej04-energia-w-min',
    'tp6-s3-ej05-energia-kw-h',
    'tp6-s3-ej06-energia-w-dias',
    'tp6-s3-ej07-promedio-kwh-dias',
    'tp6-s3-ej08-costo-lampara'
  );

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_v, @u_v, @b_v, 'V', 'V', 'Tension asignada desde banco TP6 S3.', 10 FROM ejercicios e WHERE e.codigo IN ('tp6-s3-ej01-potencia-v-ima', 'tp6-s3-ej03-potencia-v-rkohm')
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_i, @u_ma, @b_i_ma, 'I_mA', 'I_mA', 'Corriente en mA asignada desde banco TP6 S3.', 20 FROM ejercicios e WHERE e.codigo IN ('tp6-s3-ej01-potencia-v-ima', 'tp6-s3-ej02-potencia-ima-rkohm')
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_r, @u_kohm, @b_r_kohm, 'R_kohm', 'R_kohm', 'Resistencia en kohm asignada desde banco TP6 S3.', 10 FROM ejercicios e WHERE e.codigo IN ('tp6-s3-ej02-potencia-ima-rkohm', 'tp6-s3-ej03-potencia-v-rkohm')
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_p, @u_w, @b_p_w, 'P_W', 'P_W', 'Potencia en W asignada desde banco TP6 S3.', 10 FROM ejercicios e WHERE e.codigo IN ('tp6-s3-ej04-energia-w-min', 'tp6-s3-ej06-energia-w-dias')
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_t, @u_min, @b_t_min, 't_min', 't_min', 'Tiempo en min asignado desde banco TP6 S3.', 20 FROM ejercicios e WHERE e.codigo = 'tp6-s3-ej04-energia-w-min'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_p, @u_kw, @b_p_kw, 'P_kW', 'P_kW', 'Potencia en kW asignada desde banco TP6 S3.', 10 FROM ejercicios e WHERE e.codigo = 'tp6-s3-ej05-energia-kw-h'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_t, @u_h, @b_t_h, 't_h', 't_h', 'Tiempo en h asignado desde banco TP6 S3.', 20 FROM ejercicios e WHERE e.codigo = 'tp6-s3-ej05-energia-kw-h'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_n, @u_dia, @b_dias, 'dias', 'dias', 'Dias asignados desde banco TP6 S3.', 20 FROM ejercicios e WHERE e.codigo IN ('tp6-s3-ej06-energia-w-dias', 'tp6-s3-ej07-promedio-kwh-dias')
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_e, @u_kwh, @b_e_kwh, 'E_kWh', 'E_kWh', 'Energia en kWh asignada desde banco TP6 S3.', 10 FROM ejercicios e WHERE e.codigo = 'tp6-s3-ej07-promedio-kwh-dias'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_p, @u_w, @b_p_lampara, 'P_lampara_W', 'P_lampara_W', 'Potencia de lampara asignada desde banco TP6 S3.', 10 FROM ejercicios e WHERE e.codigo = 'tp6-s3-ej08-costo-lampara'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_t, @u_h_dia, @b_h_dia, 'h_dia', 'h_dia', 'Horas por dia asignadas desde banco TP6 S3.', 20 FROM ejercicios e WHERE e.codigo = 'tp6-s3-ej08-costo-lampara'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

UPDATE combinaciones_ejercicio ce
INNER JOIN ejercicios e ON e.id = ce.ejercicio_id
SET ce.activa = 0
WHERE e.actividad_id = @act3;

COMMIT;
