USE electrodesafio;

START TRANSACTION;

INSERT INTO magnitudes (nombre, simbolo) VALUES
  ('Temperatura', 'TEMP'),
  ('Altitud', 'ALT')
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), simbolo = VALUES(simbolo);

SET @mag_temp := (SELECT id FROM magnitudes WHERE simbolo = 'TEMP' LIMIT 1);
SET @mag_alt := (SELECT id FROM magnitudes WHERE simbolo = 'ALT' LIMIT 1);

INSERT INTO unidades (magnitud_id, nombre, simbolo, factor_base) VALUES
  (@mag_temp, 'grado celsius', '°C', 1),
  (@mag_alt, 'metros sobre el nivel del mar', 'm s. n. m.', 1)
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), factor_base = VALUES(factor_base);

SET @u_c := (SELECT id FROM unidades WHERE magnitud_id = @mag_temp AND simbolo = '°C' LIMIT 1);
SET @u_msnm := (SELECT id FROM unidades WHERE magnitud_id = @mag_alt AND simbolo = 'm s. n. m.' LIMIT 1);

INSERT INTO temas (nombre, descripcion, orden, activo) VALUES
  ('Mision Aconcagua', 'Campamento cientifico con numeros enteros, provisiones y organizacion del espacio.', 40, 1)
ON DUPLICATE KEY UPDATE descripcion = VALUES(descripcion), orden = VALUES(orden), activo = VALUES(activo);

SET @tema := (SELECT id FROM temas WHERE nombre = 'Mision Aconcagua' LIMIT 1);

INSERT INTO trabajos_practicos (tema_id, titulo, descripcion, codigo, activo) VALUES
  (@tema, 'Mision Aconcagua: organizar un campamento cientifico', 'El alumno integra un equipo que debe llegar a un campamento, administrar provisiones y organizar el espacio disponible.', 'mision-aconcagua-2026', 1)
ON DUPLICATE KEY UPDATE tema_id = VALUES(tema_id), titulo = VALUES(titulo), descripcion = VALUES(descripcion), activo = VALUES(activo);

SET @tp := (SELECT id FROM trabajos_practicos WHERE codigo = 'mision-aconcagua-2026' LIMIT 1);

INSERT INTO secciones_tp (trabajo_practico_id, titulo, descripcion, orden, activo) VALUES
  (@tp, 'Seccion 1 - Ascenso y clima', 'Numeros enteros aplicados a temperaturas y alturas de una expedicion al Aconcagua.', 10, 1)
ON DUPLICATE KEY UPDATE titulo = VALUES(titulo), descripcion = VALUES(descripcion), activo = VALUES(activo);

SET @sec1 := (SELECT id FROM secciones_tp WHERE trabajo_practico_id = @tp AND orden = 10 LIMIT 1);

INSERT INTO contenedores_actividad (tema_id, nombre, descripcion, orden, activo) VALUES
  (@tema, 'Mision Aconcagua', 'Actividades para mostrar a directivos: campamento cientifico y resolucion por misiones.', 10, 1)
ON DUPLICATE KEY UPDATE descripcion = VALUES(descripcion), orden = VALUES(orden), activo = VALUES(activo);

SET @contenedor := (SELECT id FROM contenedores_actividad WHERE tema_id = @tema AND nombre = 'Mision Aconcagua' LIMIT 1);

INSERT INTO actividades (contenedor_id, seccion_tp_id, titulo, descripcion, nivel, puntos, estado, visible_alumno, acceso_habilitado, puntaje_habilitado, icono, orden)
SELECT @contenedor, @sec1, 'Mision Aconcagua - Seccion 1', 'Mision Aconcagua: organizar un campamento cientifico. El alumno integra un equipo que debe llegar a un campamento, administrar provisiones y organizar el espacio disponible. Para completar la mision debe superar tres secciones de ocho ejercicios. Seccion 1: ascenso y clima.', 'Inicial', 10, 'Disponible', 1, 1, 0, 'A', 70
WHERE NOT EXISTS (
  SELECT 1 FROM actividades WHERE seccion_tp_id = @sec1 AND titulo = 'Mision Aconcagua - Seccion 1'
);

SET @act1 := (SELECT id FROM actividades WHERE seccion_tp_id = @sec1 AND titulo = 'Mision Aconcagua - Seccion 1' LIMIT 1);

UPDATE actividades
SET contenedor_id = @contenedor,
    descripcion = 'Mision Aconcagua: organizar un campamento cientifico. El alumno integra un equipo que debe llegar a un campamento, administrar provisiones y organizar el espacio disponible. Para completar la mision debe superar tres secciones de ocho ejercicios. Seccion 1: ascenso y clima.',
    nivel = 'Inicial',
    puntos = 10,
    estado = 'Disponible',
    visible_alumno = 1,
    acceso_habilitado = 1,
    puntaje_habilitado = 0,
    icono = 'A',
    orden = 70
WHERE id = @act1;

INSERT INTO bancos_valores_seccion (seccion_tp_id, magnitud_id, unidad_id, nombre, codigo, descripcion, orden, activo) VALUES
  (@sec1, @mag_temp, @u_c, 'Temperatura inicial', 'T_INICIAL_ACONCAGUA_S1', 'Temperatura inicial en grados Celsius.', 10, 1),
  (@sec1, @mag_temp, @u_c, 'Descenso de temperatura', 'DESCENSO_T_ACONCAGUA_S1', 'Descenso de temperatura en grados Celsius.', 20, 1),
  (@sec1, @mag_temp, @u_c, 'Aumento de temperatura', 'AUMENTO_T_ACONCAGUA_S1', 'Aumento de temperatura en grados Celsius.', 30, 1),
  (@sec1, @mag_temp, @u_c, 'Temperatura minima', 'T_MIN_ACONCAGUA_S1', 'Temperatura minima en grados Celsius.', 40, 1),
  (@sec1, @mag_temp, @u_c, 'Temperatura maxima', 'T_MAX_ACONCAGUA_S1', 'Temperatura maxima en grados Celsius.', 50, 1),
  (@sec1, @mag_temp, @u_c, 'Temperatura final', 'T_FINAL_ACONCAGUA_S1', 'Temperatura final en grados Celsius.', 60, 1),
  (@sec1, @mag_temp, @u_c, 'Descenso final', 'DESCENSO_FINAL_ACONCAGUA_S1', 'Descenso final de temperatura en grados Celsius.', 70, 1),
  (@sec1, @mag_alt, @u_msnm, 'Altitud inicial', 'ALTITUD_INICIAL_ACONCAGUA_S1', 'Altitud inicial en metros sobre el nivel del mar.', 80, 1),
  (@sec1, @mag_alt, @u_msnm, 'Ascenso', 'ASCENSO_ACONCAGUA_S1', 'Ascenso en metros.', 90, 1),
  (@sec1, @mag_alt, @u_msnm, 'Descenso de altitud', 'DESCENSO_ALT_ACONCAGUA_S1', 'Descenso de altitud en metros.', 100, 1)
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), nombre = VALUES(nombre), descripcion = VALUES(descripcion), orden = VALUES(orden), activo = VALUES(activo);

SET @b_ti := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec1 AND codigo = 'T_INICIAL_ACONCAGUA_S1' LIMIT 1);
SET @b_dt := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec1 AND codigo = 'DESCENSO_T_ACONCAGUA_S1' LIMIT 1);
SET @b_at := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec1 AND codigo = 'AUMENTO_T_ACONCAGUA_S1' LIMIT 1);
SET @b_tmin := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec1 AND codigo = 'T_MIN_ACONCAGUA_S1' LIMIT 1);
SET @b_tmax := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec1 AND codigo = 'T_MAX_ACONCAGUA_S1' LIMIT 1);
SET @b_tf := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec1 AND codigo = 'T_FINAL_ACONCAGUA_S1' LIMIT 1);
SET @b_df := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec1 AND codigo = 'DESCENSO_FINAL_ACONCAGUA_S1' LIMIT 1);
SET @b_alt := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec1 AND codigo = 'ALTITUD_INICIAL_ACONCAGUA_S1' LIMIT 1);
SET @b_asc := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec1 AND codigo = 'ASCENSO_ACONCAGUA_S1' LIMIT 1);
SET @b_dalt := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec1 AND codigo = 'DESCENSO_ALT_ACONCAGUA_S1' LIMIT 1);

INSERT INTO valores_banco_seccion (banco_valores_seccion_id, indice, valor, etiqueta, activo) VALUES
  (@b_ti, 1, -8, '-8 °C', 1), (@b_ti, 2, -6, '-6 °C', 1), (@b_ti, 3, -4, '-4 °C', 1), (@b_ti, 4, -2, '-2 °C', 1), (@b_ti, 5, 0, '0 °C', 1), (@b_ti, 6, 2, '2 °C', 1), (@b_ti, 7, 4, '4 °C', 1), (@b_ti, 8, 6, '6 °C', 1),
  (@b_dt, 1, 2, '2 °C', 1), (@b_dt, 2, 3, '3 °C', 1), (@b_dt, 3, 4, '4 °C', 1), (@b_dt, 4, 5, '5 °C', 1), (@b_dt, 5, 6, '6 °C', 1), (@b_dt, 6, 7, '7 °C', 1), (@b_dt, 7, 8, '8 °C', 1), (@b_dt, 8, 10, '10 °C', 1),
  (@b_at, 1, 3, '3 °C', 1), (@b_at, 2, 4, '4 °C', 1), (@b_at, 3, 5, '5 °C', 1), (@b_at, 4, 6, '6 °C', 1), (@b_at, 5, 7, '7 °C', 1), (@b_at, 6, 8, '8 °C', 1), (@b_at, 7, 10, '10 °C', 1), (@b_at, 8, 12, '12 °C', 1),
  (@b_tmin, 1, -12, '-12 °C', 1), (@b_tmin, 2, -10, '-10 °C', 1), (@b_tmin, 3, -8, '-8 °C', 1), (@b_tmin, 4, -6, '-6 °C', 1), (@b_tmin, 5, -5, '-5 °C', 1), (@b_tmin, 6, -4, '-4 °C', 1), (@b_tmin, 7, -3, '-3 °C', 1), (@b_tmin, 8, -2, '-2 °C', 1),
  (@b_tmax, 1, 2, '2 °C', 1), (@b_tmax, 2, 3, '3 °C', 1), (@b_tmax, 3, 4, '4 °C', 1), (@b_tmax, 4, 5, '5 °C', 1), (@b_tmax, 5, 6, '6 °C', 1), (@b_tmax, 6, 8, '8 °C', 1), (@b_tmax, 7, 10, '10 °C', 1), (@b_tmax, 8, 12, '12 °C', 1),
  (@b_tf, 1, -10, '-10 °C', 1), (@b_tf, 2, -8, '-8 °C', 1), (@b_tf, 3, -6, '-6 °C', 1), (@b_tf, 4, -4, '-4 °C', 1), (@b_tf, 5, -2, '-2 °C', 1), (@b_tf, 6, 0, '0 °C', 1), (@b_tf, 7, 2, '2 °C', 1), (@b_tf, 8, 4, '4 °C', 1),
  (@b_df, 1, 1, '1 °C', 1), (@b_df, 2, 2, '2 °C', 1), (@b_df, 3, 3, '3 °C', 1), (@b_df, 4, 4, '4 °C', 1), (@b_df, 5, 5, '5 °C', 1), (@b_df, 6, 6, '6 °C', 1), (@b_df, 7, 7, '7 °C', 1), (@b_df, 8, 8, '8 °C', 1),
  (@b_alt, 1, 2800, '2800 m s. n. m.', 1), (@b_alt, 2, 3000, '3000 m s. n. m.', 1), (@b_alt, 3, 3200, '3200 m s. n. m.', 1), (@b_alt, 4, 3400, '3400 m s. n. m.', 1), (@b_alt, 5, 3600, '3600 m s. n. m.', 1), (@b_alt, 6, 3800, '3800 m s. n. m.', 1), (@b_alt, 7, 4000, '4000 m s. n. m.', 1), (@b_alt, 8, 4200, '4200 m s. n. m.', 1),
  (@b_asc, 1, 100, '100 m s. n. m.', 1), (@b_asc, 2, 150, '150 m s. n. m.', 1), (@b_asc, 3, 200, '200 m s. n. m.', 1), (@b_asc, 4, 250, '250 m s. n. m.', 1), (@b_asc, 5, 300, '300 m s. n. m.', 1), (@b_asc, 6, 350, '350 m s. n. m.', 1), (@b_asc, 7, 400, '400 m s. n. m.', 1), (@b_asc, 8, 500, '500 m s. n. m.', 1),
  (@b_dalt, 1, 50, '50 m s. n. m.', 1), (@b_dalt, 2, 100, '100 m s. n. m.', 1), (@b_dalt, 3, 150, '150 m s. n. m.', 1), (@b_dalt, 4, 200, '200 m s. n. m.', 1), (@b_dalt, 5, 250, '250 m s. n. m.', 1), (@b_dalt, 6, 300, '300 m s. n. m.', 1), (@b_dalt, 7, 350, '350 m s. n. m.', 1), (@b_dalt, 8, 400, '400 m s. n. m.', 1)
ON DUPLICATE KEY UPDATE valor = VALUES(valor), etiqueta = VALUES(etiqueta), activo = VALUES(activo);

INSERT INTO ejercicios (actividad_id, seccion_tp_id, codigo, consigna, explicacion, formula_respuesta, tolerancia, orden, activo) VALUES
  (@act1, @sec1, 'aconcagua-s1-ej01-descenso-temperatura', 'En el campamento, la temperatura inicial era de {T_INICIAL}. Durante la noche descendio {DESCENSO_T}. ¿Cual fue la temperatura final?', 'Reste el descenso a la temperatura inicial.', 'T_INICIAL - DESCENSO_T', 0, 10, 1),
  (@act1, @sec1, 'aconcagua-s1-ej02-aumento-temperatura', 'Al amanecer, la temperatura era de {T_INICIAL}. Durante la mañana aumento {AUMENTO_T}. ¿Que temperatura se alcanzo?', 'Sume el aumento a la temperatura inicial.', 'T_INICIAL + AUMENTO_T', 0, 20, 1),
  (@act1, @sec1, 'aconcagua-s1-ej03-amplitud-termica', 'Durante una jornada, la temperatura minima fue de {T_MIN} y la maxima fue de {T_MAX}. ¿Cuantos grados de diferencia hubo entre ambas temperaturas?', 'Reste la temperatura minima a la maxima.', 'T_MAX - T_MIN', 0, 30, 1),
  (@act1, @sec1, 'aconcagua-s1-ej04-ascenso-campamentos', 'Un grupo se encuentra a {ALTITUD_INICIAL} y asciende {ASCENSO}. ¿A que altitud llega?', 'Sume el ascenso a la altitud inicial.', 'ALTITUD_INICIAL + ASCENSO', 0, 40, 1),
  (@act1, @sec1, 'aconcagua-s1-ej05-descenso-refugio', 'Un equipo se encuentra a {ALTITUD_INICIAL} y desciende {DESCENSO_ALT}. ¿A que altitud queda?', 'Reste el descenso a la altitud inicial.', 'ALTITUD_INICIAL - DESCENSO_ALT', 0, 50, 1),
  (@act1, @sec1, 'aconcagua-s1-ej06-recorrido-combinado', 'Una expedicion comienza a {ALTITUD_INICIAL}. Primero asciende {ASCENSO} y luego desciende {DESCENSO_ALT}. ¿A que altitud termina el recorrido?', 'Sume el ascenso y luego reste el descenso.', 'ALTITUD_INICIAL + ASCENSO - DESCENSO_ALT', 0, 60, 1),
  (@act1, @sec1, 'aconcagua-s1-ej07-temperatura-inicial-desconocida', 'En el campamento, despues de una bajada de {DESCENSO_T}, el termometro quedo en {T_FINAL}. Que temperatura habia antes de esa bajada?', 'Para recuperar la temperatura anterior, sume el descenso a la temperatura final.', 'T_FINAL + DESCENSO_T', 0, 70, 1),
  (@act1, @sec1, 'aconcagua-s1-ej08-cambios-sucesivos-temperatura', 'Al comenzar la jornada, la temperatura era de {T_INICIAL}. Durante la madrugada descendio {DESCENSO_T}, por la mañana aumento {AUMENTO_T} y por la tarde volvio a descender {DESCENSO_FINAL}. ¿Cual fue la temperatura al finalizar la jornada?', 'Aplique los cambios consecutivos respetando los signos.', 'T_INICIAL - DESCENSO_T + AUMENTO_T - DESCENSO_FINAL', 0, 80, 1)
ON DUPLICATE KEY UPDATE actividad_id = VALUES(actividad_id), seccion_tp_id = VALUES(seccion_tp_id), consigna = VALUES(consigna), explicacion = VALUES(explicacion), formula_respuesta = VALUES(formula_respuesta), tolerancia = VALUES(tolerancia), orden = VALUES(orden), activo = VALUES(activo);

UPDATE ejercicios
SET activo = 0
WHERE actividad_id = @act1
  AND codigo NOT IN (
    'aconcagua-s1-ej01-descenso-temperatura',
    'aconcagua-s1-ej02-aumento-temperatura',
    'aconcagua-s1-ej03-amplitud-termica',
    'aconcagua-s1-ej04-ascenso-campamentos',
    'aconcagua-s1-ej05-descenso-refugio',
    'aconcagua-s1-ej06-recorrido-combinado',
    'aconcagua-s1-ej07-temperatura-inicial-desconocida',
    'aconcagua-s1-ej08-cambios-sucesivos-temperatura'
  );

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_temp, @u_c, @b_ti, 'T_INICIAL', 'T_INICIAL', 'Temperatura inicial asignada desde banco Aconcagua S1.', 10 FROM ejercicios e WHERE e.codigo IN ('aconcagua-s1-ej01-descenso-temperatura', 'aconcagua-s1-ej02-aumento-temperatura', 'aconcagua-s1-ej08-cambios-sucesivos-temperatura')
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_temp, @u_c, @b_dt, 'DESCENSO_T', 'DESCENSO_T', 'Descenso de temperatura asignado desde banco Aconcagua S1.', 20 FROM ejercicios e WHERE e.codigo IN ('aconcagua-s1-ej01-descenso-temperatura', 'aconcagua-s1-ej07-temperatura-inicial-desconocida', 'aconcagua-s1-ej08-cambios-sucesivos-temperatura')
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_temp, @u_c, @b_at, 'AUMENTO_T', 'AUMENTO_T', 'Aumento de temperatura asignado desde banco Aconcagua S1.', 20 FROM ejercicios e WHERE e.codigo IN ('aconcagua-s1-ej02-aumento-temperatura', 'aconcagua-s1-ej08-cambios-sucesivos-temperatura')
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_temp, @u_c, @b_tmin, 'T_MIN', 'T_MIN', 'Temperatura minima asignada desde banco Aconcagua S1.', 10 FROM ejercicios e WHERE e.codigo = 'aconcagua-s1-ej03-amplitud-termica'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_temp, @u_c, @b_tmax, 'T_MAX', 'T_MAX', 'Temperatura maxima asignada desde banco Aconcagua S1.', 20 FROM ejercicios e WHERE e.codigo = 'aconcagua-s1-ej03-amplitud-termica'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_temp, @u_c, @b_tf, 'T_FINAL', 'T_FINAL', 'Temperatura final asignada desde banco Aconcagua S1.', 10 FROM ejercicios e WHERE e.codigo = 'aconcagua-s1-ej07-temperatura-inicial-desconocida'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_temp, @u_c, @b_df, 'DESCENSO_FINAL', 'DESCENSO_FINAL', 'Descenso final asignado desde banco Aconcagua S1.', 40 FROM ejercicios e WHERE e.codigo = 'aconcagua-s1-ej08-cambios-sucesivos-temperatura'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_alt, @u_msnm, @b_alt, 'ALTITUD_INICIAL', 'ALTITUD_INICIAL', 'Altitud inicial asignada desde banco Aconcagua S1.', 10 FROM ejercicios e WHERE e.codigo IN ('aconcagua-s1-ej04-ascenso-campamentos', 'aconcagua-s1-ej05-descenso-refugio', 'aconcagua-s1-ej06-recorrido-combinado')
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_alt, @u_msnm, @b_asc, 'ASCENSO', 'ASCENSO', 'Ascenso asignado desde banco Aconcagua S1.', 20 FROM ejercicios e WHERE e.codigo IN ('aconcagua-s1-ej04-ascenso-campamentos', 'aconcagua-s1-ej06-recorrido-combinado')
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_alt, @u_msnm, @b_dalt, 'DESCENSO_ALT', 'DESCENSO_ALT', 'Descenso de altitud asignado desde banco Aconcagua S1.', 30 FROM ejercicios e WHERE e.codigo IN ('aconcagua-s1-ej05-descenso-refugio', 'aconcagua-s1-ej06-recorrido-combinado')
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

UPDATE combinaciones_ejercicio ce
INNER JOIN ejercicios e ON e.id = ce.ejercicio_id
SET ce.activa = 0
WHERE e.actividad_id = @act1;

COMMIT;
