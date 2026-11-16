USE electrodesafio;
SET NAMES utf8mb4;

START TRANSACTION;

INSERT INTO magnitudes (nombre, simbolo) VALUES
  ('Cantidad', 'N'),
  ('Potencia', 'P'),
  ('Energia', 'E'),
  ('Tiempo', 't')
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), simbolo = VALUES(simbolo);

SET @mag_n := (SELECT id FROM magnitudes WHERE simbolo = 'N' LIMIT 1);
SET @mag_p := (SELECT id FROM magnitudes WHERE simbolo = 'P' LIMIT 1);
SET @mag_e := (SELECT id FROM magnitudes WHERE simbolo = 'E' LIMIT 1);
SET @mag_t := (SELECT id FROM magnitudes WHERE simbolo = 't' LIMIT 1);

INSERT INTO unidades (magnitud_id, nombre, simbolo, factor_base) VALUES
  (@mag_n, 'unidad', 'u', 1),
  (@mag_p, 'watt', 'W', 1),
  (@mag_p, 'kilowatt', 'kW', 1000),
  (@mag_p, 'miliwatt', 'mW', 0.001),
  (@mag_p, 'megawatt', 'MW', 1000000),
  (@mag_e, 'joule', 'J', 1),
  (@mag_e, 'kilojoule', 'kJ', 1000),
  (@mag_e, 'kilowatt hora', 'kWh', 3600000),
  (@mag_t, 'segundo', 's', 1),
  (@mag_t, 'minuto', 'min', 60),
  (@mag_t, 'hora', 'h', 3600)
ON DUPLICATE KEY UPDATE
  nombre = VALUES(nombre),
  factor_base = VALUES(factor_base);

SET @u_unidad := (SELECT id FROM unidades WHERE magnitud_id = @mag_n AND simbolo = 'u' LIMIT 1);
SET @u_w := (SELECT id FROM unidades WHERE magnitud_id = @mag_p AND simbolo = 'W' LIMIT 1);
SET @u_kw := (SELECT id FROM unidades WHERE magnitud_id = @mag_p AND simbolo = 'kW' LIMIT 1);
SET @u_mw := (SELECT id FROM unidades WHERE magnitud_id = @mag_p AND simbolo = 'mW' LIMIT 1);
SET @u_mw_big := (SELECT id FROM unidades WHERE magnitud_id = @mag_p AND simbolo = 'MW' LIMIT 1);
SET @u_j := (SELECT id FROM unidades WHERE magnitud_id = @mag_e AND simbolo = 'J' LIMIT 1);
SET @u_kj := (SELECT id FROM unidades WHERE magnitud_id = @mag_e AND simbolo = 'kJ' LIMIT 1);
SET @u_s := (SELECT id FROM unidades WHERE magnitud_id = @mag_t AND simbolo = 's' LIMIT 1);
SET @u_min := (SELECT id FROM unidades WHERE magnitud_id = @mag_t AND simbolo = 'min' LIMIT 1);
SET @u_h := (SELECT id FROM unidades WHERE magnitud_id = @mag_t AND simbolo = 'h' LIMIT 1);

INSERT INTO temas (nombre, descripcion, orden, activo) VALUES
  ('Energia y potencia', 'Potencia, energia, tiempo y conversiones de unidades.', 30, 1)
ON DUPLICATE KEY UPDATE
  descripcion = VALUES(descripcion),
  orden = VALUES(orden),
  activo = VALUES(activo);

SET @tema := (SELECT id FROM temas WHERE nombre = 'Energia y potencia' LIMIT 1);

INSERT INTO trabajos_practicos (tema_id, titulo, descripcion, codigo, activo) VALUES
  (@tema, 'TP 06 - Energia y potencia', 'Trabajo practico dividido en secciones para energia, potencia y conversiones.', 'tp6-energia-potencia-2026', 1)
ON DUPLICATE KEY UPDATE
  tema_id = VALUES(tema_id),
  titulo = VALUES(titulo),
  descripcion = VALUES(descripcion),
  activo = VALUES(activo);

SET @tp6 := (SELECT id FROM trabajos_practicos WHERE codigo = 'tp6-energia-potencia-2026' LIMIT 1);

INSERT INTO secciones_tp (trabajo_practico_id, titulo, descripcion, orden, activo) VALUES
  (@tp6, 'Seccion 1 - Unidades, energia y potencia', 'Conversiones y relaciones P = E / t y E = P x t.', 10, 1),
  (@tp6, 'Seccion 2 - Pendiente de carga', 'Seccion pendiente de definicion.', 20, 1),
  (@tp6, 'Seccion 3 - Pendiente de carga', 'Seccion pendiente de definicion.', 30, 1)
ON DUPLICATE KEY UPDATE
  titulo = VALUES(titulo),
  descripcion = VALUES(descripcion),
  activo = VALUES(activo);

SET @sec1 := (SELECT id FROM secciones_tp WHERE trabajo_practico_id = @tp6 AND orden = 10 LIMIT 1);

INSERT INTO contenedores_actividad (tema_id, nombre, descripcion, orden, activo) VALUES
  (@tema, 'TP 6', 'Actividades del TP 6 de energia y potencia.', 10, 1)
ON DUPLICATE KEY UPDATE
  descripcion = VALUES(descripcion),
  orden = VALUES(orden),
  activo = VALUES(activo);

SET @contenedor := (SELECT id FROM contenedores_actividad WHERE tema_id = @tema AND nombre = 'TP 6' LIMIT 1);

INSERT INTO actividades (contenedor_id, seccion_tp_id, titulo, descripcion, nivel, puntos, estado, visible_alumno, acceso_habilitado, puntaje_habilitado, icono, orden)
SELECT @contenedor, @sec1, 'TP6 - Seccion 1', 'Unidades, energia y potencia con conversiones basicas.', 'Inicial', 10, 'Disponible', 1, 1, 0, 'P', 40
WHERE NOT EXISTS (
  SELECT 1 FROM actividades WHERE seccion_tp_id = @sec1 AND titulo = 'TP6 - Seccion 1'
);

SET @act1 := (SELECT id FROM actividades WHERE seccion_tp_id = @sec1 AND titulo = 'TP6 - Seccion 1' LIMIT 1);

UPDATE actividades
SET contenedor_id = @contenedor,
    descripcion = 'Unidades, energia y potencia con conversiones basicas.',
    nivel = 'Inicial',
    puntos = 10,
    estado = 'Disponible',
    visible_alumno = 1,
    acceso_habilitado = 1,
    puntaje_habilitado = 0,
    icono = 'P',
    orden = 40
WHERE id = @act1;

INSERT INTO bancos_valores_seccion (seccion_tp_id, magnitud_id, unidad_id, nombre, codigo, descripcion, orden, activo) VALUES
  (@sec1, @mag_n, @u_unidad, 'Cantidad de equipos', 'N_TP6_S1', 'Cantidad de lamparas, motores, dispositivos o generadores.', 10, 1),
  (@sec1, @mag_p, @u_w, 'Potencia en watts', 'P_W_TP6_S1', 'Potencias expresadas en watts.', 20, 1),
  (@sec1, @mag_p, @u_kw, 'Potencia en kilowatts', 'P_KW_TP6_S1', 'Potencias expresadas en kilowatts.', 30, 1),
  (@sec1, @mag_p, @u_mw, 'Potencia en miliwatts', 'P_MW_TP6_S1', 'Potencias expresadas en miliwatts.', 40, 1),
  (@sec1, @mag_p, @u_mw_big, 'Potencia en megawatts', 'P_MEGW_TP6_S1', 'Potencias expresadas en megawatts.', 50, 1),
  (@sec1, @mag_e, @u_j, 'Energia en joules', 'E_J_TP6_S1', 'Energias expresadas en joules.', 60, 1),
  (@sec1, @mag_t, @u_s, 'Tiempo en segundos', 'T_S_TP6_S1', 'Tiempos expresados en segundos.', 70, 1),
  (@sec1, @mag_e, @u_kj, 'Energia en kilojoules', 'E_KJ_TP6_S1', 'Energias expresadas en kilojoules.', 80, 1),
  (@sec1, @mag_t, @u_min, 'Tiempo en minutos', 'T_MIN_TP6_S1', 'Tiempos expresados en minutos.', 90, 1),
  (@sec1, @mag_t, @u_h, 'Tiempo en horas', 'T_H_TP6_S1', 'Tiempos expresados en horas.', 100, 1)
ON DUPLICATE KEY UPDATE
  magnitud_id = VALUES(magnitud_id),
  unidad_id = VALUES(unidad_id),
  nombre = VALUES(nombre),
  descripcion = VALUES(descripcion),
  orden = VALUES(orden),
  activo = VALUES(activo);

SET @b_n := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec1 AND codigo = 'N_TP6_S1' LIMIT 1);
SET @b_pw := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec1 AND codigo = 'P_W_TP6_S1' LIMIT 1);
SET @b_pkw := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec1 AND codigo = 'P_KW_TP6_S1' LIMIT 1);
SET @b_pmw := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec1 AND codigo = 'P_MW_TP6_S1' LIMIT 1);
SET @b_pmegw := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec1 AND codigo = 'P_MEGW_TP6_S1' LIMIT 1);
SET @b_ej := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec1 AND codigo = 'E_J_TP6_S1' LIMIT 1);
SET @b_ts := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec1 AND codigo = 'T_S_TP6_S1' LIMIT 1);
SET @b_ekj := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec1 AND codigo = 'E_KJ_TP6_S1' LIMIT 1);
SET @b_tmin := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec1 AND codigo = 'T_MIN_TP6_S1' LIMIT 1);
SET @b_th := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec1 AND codigo = 'T_H_TP6_S1' LIMIT 1);

INSERT INTO valores_banco_seccion (banco_valores_seccion_id, indice, valor, etiqueta, activo) VALUES
  (@b_n, 1, 1, '1', 1), (@b_n, 2, 2, '2', 1), (@b_n, 3, 3, '3', 1), (@b_n, 4, 4, '4', 1),
  (@b_n, 5, 5, '5', 1), (@b_n, 6, 6, '6', 1), (@b_n, 7, 8, '8', 1), (@b_n, 8, 10, '10', 1),
  (@b_pw, 1, 1000, '1000 W', 1), (@b_pw, 2, 1500, '1500 W', 1), (@b_pw, 3, 2500, '2500 W', 1), (@b_pw, 4, 3200, '3200 W', 1),
  (@b_pw, 5, 5000, '5000 W', 1), (@b_pw, 6, 7500, '7500 W', 1), (@b_pw, 7, 12000, '12000 W', 1), (@b_pw, 8, 50000, '50000 W', 1),
  (@b_pkw, 1, 0.5, '0,5 kW', 1), (@b_pkw, 2, 1, '1 kW', 1), (@b_pkw, 3, 1.2, '1,2 kW', 1), (@b_pkw, 4, 2.5, '2,5 kW', 1),
  (@b_pkw, 5, 3.75, '3,75 kW', 1), (@b_pkw, 6, 5, '5 kW', 1), (@b_pkw, 7, 8.7, '8,7 kW', 1), (@b_pkw, 8, 12, '12 kW', 1),
  (@b_pmw, 1, 100, '100 mW', 1), (@b_pmw, 2, 250, '250 mW', 1), (@b_pmw, 3, 400, '400 mW', 1), (@b_pmw, 4, 750, '750 mW', 1),
  (@b_pmw, 5, 1200, '1200 mW', 1), (@b_pmw, 6, 2500, '2500 mW', 1), (@b_pmw, 7, 5000, '5000 mW', 1), (@b_pmw, 8, 9000, '9000 mW', 1),
  (@b_pmegw, 1, 0.5, '0,5 MW', 1), (@b_pmegw, 2, 1, '1 MW', 1), (@b_pmegw, 3, 1.5, '1,5 MW', 1), (@b_pmegw, 4, 2, '2 MW', 1),
  (@b_pmegw, 5, 2.5, '2,5 MW', 1), (@b_pmegw, 6, 3, '3 MW', 1), (@b_pmegw, 7, 4, '4 MW', 1), (@b_pmegw, 8, 5, '5 MW', 1),
  (@b_ej, 1, 120, '120 J', 1), (@b_ej, 2, 240, '240 J', 1), (@b_ej, 3, 360, '360 J', 1), (@b_ej, 4, 600, '600 J', 1),
  (@b_ej, 5, 900, '900 J', 1), (@b_ej, 6, 1200, '1200 J', 1), (@b_ej, 7, 1800, '1800 J', 1), (@b_ej, 8, 2400, '2400 J', 1),
  (@b_ts, 1, 2, '2 s', 1), (@b_ts, 2, 3, '3 s', 1), (@b_ts, 3, 4, '4 s', 1), (@b_ts, 4, 5, '5 s', 1),
  (@b_ts, 5, 6, '6 s', 1), (@b_ts, 6, 8, '8 s', 1), (@b_ts, 7, 10, '10 s', 1), (@b_ts, 8, 12, '12 s', 1),
  (@b_ekj, 1, 36, '36 kJ', 1), (@b_ekj, 2, 72, '72 kJ', 1), (@b_ekj, 3, 108, '108 kJ', 1), (@b_ekj, 4, 180, '180 kJ', 1),
  (@b_ekj, 5, 360, '360 kJ', 1), (@b_ekj, 6, 540, '540 kJ', 1), (@b_ekj, 7, 720, '720 kJ', 1), (@b_ekj, 8, 1080, '1080 kJ', 1),
  (@b_tmin, 1, 1, '1 min', 1), (@b_tmin, 2, 2, '2 min', 1), (@b_tmin, 3, 3, '3 min', 1), (@b_tmin, 4, 5, '5 min', 1),
  (@b_tmin, 5, 6, '6 min', 1), (@b_tmin, 6, 10, '10 min', 1), (@b_tmin, 7, 12, '12 min', 1), (@b_tmin, 8, 15, '15 min', 1),
  (@b_th, 1, 1, '1 h', 1), (@b_th, 2, 2, '2 h', 1), (@b_th, 3, 3, '3 h', 1), (@b_th, 4, 4, '4 h', 1),
  (@b_th, 5, 5, '5 h', 1), (@b_th, 6, 6, '6 h', 1), (@b_th, 7, 8, '8 h', 1), (@b_th, 8, 10, '10 h', 1)
ON DUPLICATE KEY UPDATE valor = VALUES(valor), etiqueta = VALUES(etiqueta), activo = VALUES(activo);

INSERT INTO ejercicios (actividad_id, seccion_tp_id, codigo, consigna, explicacion, formula_respuesta, tolerancia, orden, activo) VALUES
  (@act1, @sec1, 'tp6-s1-ej01-potencia-lamparas-kw', 'En un aula hay {N} lamparas iguales y cada una consume {P_W}. Determine la potencia total y exprese el resultado en kilowatts.', 'Calcule la potencia total multiplicando la cantidad por la potencia de cada lampara. Puede expresar el resultado en kW.', 'N * P', 0.05, 10, 1),
  (@act1, @sec1, 'tp6-s1-ej02-potencia-motores-w', 'Un taller utiliza {N} motores de {P_kW} cada uno. Determine la potencia total instalada y exprese el resultado en watts.', 'Convierta kW a W y multiplique por la cantidad de motores.', 'N * P', 0.05, 20, 1),
  (@act1, @sec1, 'tp6-s1-ej03-potencia-dispositivos-w', 'Un sistema posee {N} dispositivos electronicos de {P_mW} cada uno. Calcule la potencia total y expresela en watts.', 'Convierta mW a W y multiplique por la cantidad de dispositivos.', 'N * P', 0.05, 30, 1),
  (@act1, @sec1, 'tp6-s1-ej04-potencia-generadores-kw', 'Una central posee {N} generadores de {P_MW} cada uno. Determine la potencia total y expresela en kilowatts.', 'Convierta MW a W y exprese el resultado final en kW.', 'N * P', 0.05, 40, 1),
  (@act1, @sec1, 'tp6-s1-ej05-potencia-energia-tiempo-w', 'Un equipo consume {E_J} de energia durante {t_s}. Determine su potencia.', 'Aplique P = E / t.', 'E / T', 0.05, 50, 1),
  (@act1, @sec1, 'tp6-s1-ej06-potencia-media-kj-min-w', 'Una maquina consume {E_kJ} durante {t_min}. Determine su potencia media.', 'Convierta kJ a J y minutos a segundos, luego aplique P = E / t.', 'E / T', 0.05, 60, 1),
  (@act1, @sec1, 'tp6-s1-ej07-energia-w-s-j', 'Un dispositivo de {P_W} permanece funcionando durante {t_s}. Determine la energia consumida.', 'Aplique E = P x t.', 'P * T', 0.05, 70, 1),
  (@act1, @sec1, 'tp6-s1-ej08-energia-kw-h-kwh', 'Una maquina de {P_kW} funciona durante {t_h}. Determine la energia consumida.', 'Multiplique potencia por tiempo. Puede expresar el resultado en kWh.', 'P * T', 0.05, 80, 1)
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
    'tp6-s1-ej01-potencia-lamparas-kw',
    'tp6-s1-ej02-potencia-motores-w',
    'tp6-s1-ej03-potencia-dispositivos-w',
    'tp6-s1-ej04-potencia-generadores-kw',
    'tp6-s1-ej05-potencia-energia-tiempo-w',
    'tp6-s1-ej06-potencia-media-kj-min-w',
    'tp6-s1-ej07-energia-w-s-j',
    'tp6-s1-ej08-energia-kw-h-kwh'
  );

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_n, @u_unidad, @b_n, 'N', 'N', 'Cantidad asignada desde banco de TP6 seccion 1.', 10
FROM ejercicios e
WHERE e.codigo IN (
  'tp6-s1-ej01-potencia-lamparas-kw',
  'tp6-s1-ej02-potencia-motores-w',
  'tp6-s1-ej03-potencia-dispositivos-w',
  'tp6-s1-ej04-potencia-generadores-kw'
)
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_p, @u_w, @b_pw, 'P_W', 'P_W', 'Potencia en W asignada desde banco de TP6 seccion 1.', 20
FROM ejercicios e
WHERE e.codigo IN ('tp6-s1-ej01-potencia-lamparas-kw', 'tp6-s1-ej07-energia-w-s-j')
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_p, @u_kw, @b_pkw, 'P_kW', 'P_kW', 'Potencia en kW asignada desde banco de TP6 seccion 1.', 20
FROM ejercicios e
WHERE e.codigo IN ('tp6-s1-ej02-potencia-motores-w', 'tp6-s1-ej08-energia-kw-h-kwh')
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_p, @u_mw, @b_pmw, 'P_mW', 'P_mW', 'Potencia en mW asignada desde banco de TP6 seccion 1.', 20
FROM ejercicios e
WHERE e.codigo = 'tp6-s1-ej03-potencia-dispositivos-w'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_p, @u_mw_big, @b_pmegw, 'P_MW', 'P_MW', 'Potencia en MW asignada desde banco de TP6 seccion 1.', 20
FROM ejercicios e
WHERE e.codigo = 'tp6-s1-ej04-potencia-generadores-kw'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_e, @u_j, @b_ej, 'E_J', 'E_J', 'Energia en J asignada desde banco de TP6 seccion 1.', 10
FROM ejercicios e
WHERE e.codigo = 'tp6-s1-ej05-potencia-energia-tiempo-w'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_e, @u_kj, @b_ekj, 'E_kJ', 'E_kJ', 'Energia en kJ asignada desde banco de TP6 seccion 1.', 10
FROM ejercicios e
WHERE e.codigo = 'tp6-s1-ej06-potencia-media-kj-min-w'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_t, @u_s, @b_ts, 't_s', 't_s', 'Tiempo en s asignado desde banco de TP6 seccion 1.', 30
FROM ejercicios e
WHERE e.codigo IN ('tp6-s1-ej05-potencia-energia-tiempo-w', 'tp6-s1-ej07-energia-w-s-j')
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_t, @u_min, @b_tmin, 't_min', 't_min', 'Tiempo en min asignado desde banco de TP6 seccion 1.', 30
FROM ejercicios e
WHERE e.codigo = 'tp6-s1-ej06-potencia-media-kj-min-w'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_t, @u_h, @b_th, 't_h', 't_h', 'Tiempo en h asignado desde banco de TP6 seccion 1.', 30
FROM ejercicios e
WHERE e.codigo = 'tp6-s1-ej08-energia-kw-h-kwh'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

UPDATE combinaciones_ejercicio ce
INNER JOIN ejercicios e ON e.id = ce.ejercicio_id
SET ce.activa = 0
WHERE e.actividad_id = @act1;

COMMIT;
