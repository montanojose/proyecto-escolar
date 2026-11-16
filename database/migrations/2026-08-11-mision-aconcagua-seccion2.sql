USE electrodesafio;

START TRANSACTION;

INSERT INTO magnitudes (nombre, simbolo) VALUES
  ('Raciones', 'RAC'),
  ('Fraccion', 'FRAC'),
  ('Distancia', 'DIST'),
  ('Masa en gramos', 'MASS_G'),
  ('Masa por persona', 'MASS_PERSONA'),
  ('Masa en kilogramos', 'MASS_KG'),
  ('Personas', 'PERS'),
  ('Elementos', 'ELEM'),
  ('Cajas', 'CAJA')
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), simbolo = VALUES(simbolo);

SET @mag_rac := (SELECT id FROM magnitudes WHERE simbolo = 'RAC' LIMIT 1);
SET @mag_frac := (SELECT id FROM magnitudes WHERE simbolo = 'FRAC' LIMIT 1);
SET @mag_dist := (SELECT id FROM magnitudes WHERE simbolo = 'DIST' LIMIT 1);
SET @mag_g := (SELECT id FROM magnitudes WHERE simbolo = 'MASS_G' LIMIT 1);
SET @mag_gp := (SELECT id FROM magnitudes WHERE simbolo = 'MASS_PERSONA' LIMIT 1);
SET @mag_kg := (SELECT id FROM magnitudes WHERE simbolo = 'MASS_KG' LIMIT 1);
SET @mag_pers := (SELECT id FROM magnitudes WHERE simbolo = 'PERS' LIMIT 1);
SET @mag_elem := (SELECT id FROM magnitudes WHERE simbolo = 'ELEM' LIMIT 1);
SET @mag_caja := (SELECT id FROM magnitudes WHERE simbolo = 'CAJA' LIMIT 1);

INSERT INTO unidades (magnitud_id, nombre, simbolo, factor_base) VALUES
  (@mag_rac, 'raciones', 'raciones', 1),
  (@mag_frac, 'fraccion', '', 1),
  (@mag_dist, 'kilometros', 'km', 1),
  (@mag_g, 'gramos', 'g', 1),
  (@mag_gp, 'gramos por persona', 'g/persona', 1),
  (@mag_kg, 'kilogramos', 'kg', 1),
  (@mag_pers, 'personas', '', 1),
  (@mag_elem, 'elementos', '', 1),
  (@mag_caja, 'cajas', 'cajas', 1)
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), factor_base = VALUES(factor_base);

SET @u_rac := (SELECT id FROM unidades WHERE magnitud_id = @mag_rac AND simbolo = 'raciones' LIMIT 1);
SET @u_frac := (SELECT id FROM unidades WHERE magnitud_id = @mag_frac AND simbolo = '' LIMIT 1);
SET @u_km := (SELECT id FROM unidades WHERE magnitud_id = @mag_dist AND simbolo = 'km' LIMIT 1);
SET @u_g := (SELECT id FROM unidades WHERE magnitud_id = @mag_g AND simbolo = 'g' LIMIT 1);
SET @u_gp := (SELECT id FROM unidades WHERE magnitud_id = @mag_gp AND simbolo = 'g/persona' LIMIT 1);
SET @u_kg := (SELECT id FROM unidades WHERE magnitud_id = @mag_kg AND simbolo = 'kg' LIMIT 1);
SET @u_pers := (SELECT id FROM unidades WHERE magnitud_id = @mag_pers AND simbolo = '' LIMIT 1);
SET @u_elem := (SELECT id FROM unidades WHERE magnitud_id = @mag_elem AND simbolo = '' LIMIT 1);
SET @u_caja := (SELECT id FROM unidades WHERE magnitud_id = @mag_caja AND simbolo = 'cajas' LIMIT 1);

SET @tema := (SELECT id FROM temas WHERE nombre = 'Mision Aconcagua' LIMIT 1);
SET @tp := (SELECT id FROM trabajos_practicos WHERE codigo = 'mision-aconcagua-2026' LIMIT 1);
SET @contenedor := (SELECT id FROM contenedores_actividad WHERE tema_id = @tema AND nombre = 'Mision Aconcagua' LIMIT 1);

INSERT INTO secciones_tp (trabajo_practico_id, titulo, descripcion, orden, activo) VALUES
  (@tp, 'Seccion 2 - Administracion de provisiones', 'Fracciones y numeros racionales aplicados al reparto, consumo y administracion de provisiones.', 20, 1)
ON DUPLICATE KEY UPDATE titulo = VALUES(titulo), descripcion = VALUES(descripcion), activo = VALUES(activo);

SET @sec2 := (SELECT id FROM secciones_tp WHERE trabajo_practico_id = @tp AND orden = 20 LIMIT 1);

INSERT INTO actividades (contenedor_id, seccion_tp_id, titulo, descripcion, nivel, puntos, estado, visible_alumno, acceso_habilitado, puntaje_habilitado, icono, orden)
SELECT @contenedor, @sec2, 'Mision Aconcagua - Seccion 2', 'Mision Aconcagua: organizar un campamento cientifico. En esta etapa, el equipo debe organizar el agua, los alimentos y los materiales necesarios para continuar la expedicion. Seccion 2: administracion de provisiones.', 'Inicial', 10, 'Disponible', 1, 1, 0, 'A', 80
WHERE NOT EXISTS (
  SELECT 1 FROM actividades WHERE seccion_tp_id = @sec2 AND titulo = 'Mision Aconcagua - Seccion 2'
);

SET @act2 := (SELECT id FROM actividades WHERE seccion_tp_id = @sec2 AND titulo = 'Mision Aconcagua - Seccion 2' LIMIT 1);

UPDATE actividades
SET contenedor_id = @contenedor,
    descripcion = 'Mision Aconcagua: organizar un campamento cientifico. En esta etapa, el equipo debe organizar el agua, los alimentos y los materiales necesarios para continuar la expedicion. Seccion 2: administracion de provisiones.',
    nivel = 'Inicial',
    puntos = 10,
    estado = 'Disponible',
    visible_alumno = 1,
    acceso_habilitado = 1,
    puntaje_habilitado = 0,
    icono = 'A',
    orden = 80
WHERE id = @act2;

INSERT INTO bancos_valores_seccion (seccion_tp_id, magnitud_id, unidad_id, nombre, codigo, descripcion, orden, activo) VALUES
  (@sec2, @mag_rac, @u_rac, 'Total de raciones', 'TOTAL_RACIONES_ACONCAGUA_S2', 'Total de raciones disponibles.', 10, 1),
  (@sec2, @mag_frac, @u_frac, 'Fraccion de raciones', 'FRACCION_RACIONES_ACONCAGUA_S2', 'Fraccion del total expresada como etiqueta.', 20, 1),
  (@sec2, @mag_dist, @u_km, 'Kilometros recorridos', 'KM_RECORRIDOS_ACONCAGUA_S2', 'Kilometros recorridos en la etapa.', 30, 1),
  (@sec2, @mag_dist, @u_km, 'Kilometros totales', 'KM_TOTAL_ACONCAGUA_S2', 'Kilometros totales del trayecto.', 40, 1),
  (@sec2, @mag_g, @u_g, 'Alimento para repartir', 'ALIMENTO_G_ACONCAGUA_S2', 'Alimento disponible para repartir.', 50, 1),
  (@sec2, @mag_pers, @u_pers, 'Personas reparto', 'PERSONAS_REPARTO_ACONCAGUA_S2', 'Integrantes que reciben alimento.', 60, 1),
  (@sec2, @mag_g, @u_g, 'Racion por integrante', 'RACION_G_ACONCAGUA_S2', 'Racion de alimento por integrante.', 70, 1),
  (@sec2, @mag_pers, @u_pers, 'Personas', 'PERSONAS_ACONCAGUA_S2', 'Integrantes del equipo.', 80, 1),
  (@sec2, @mag_elem, @u_elem, 'Elementos', 'ELEMENTOS_ACONCAGUA_S2', 'Elementos a transportar.', 90, 1),
  (@sec2, @mag_elem, @u_elem, 'Capacidad de caja', 'CAPACIDAD_CAJA_ACONCAGUA_S2', 'Capacidad maxima de cada caja.', 100, 1),
  (@sec2, @mag_kg, @u_kg, 'Total alimento kg', 'TOTAL_ALIMENTO_KG_ACONCAGUA_S2', 'Alimento inicial en kilogramos.', 110, 1),
  (@sec2, @mag_frac, @u_frac, 'Fraccion etapa 1', 'FRACCION_ETAPA_1_ACONCAGUA_S2', 'Fraccion consumida en la primera etapa.', 120, 1),
  (@sec2, @mag_frac, @u_frac, 'Fraccion etapa 2', 'FRACCION_ETAPA_2_ACONCAGUA_S2', 'Fraccion consumida en la segunda etapa.', 130, 1)
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), nombre = VALUES(nombre), descripcion = VALUES(descripcion), orden = VALUES(orden), activo = VALUES(activo);

SET @b_total_rac := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec2 AND codigo = 'TOTAL_RACIONES_ACONCAGUA_S2' LIMIT 1);
SET @b_frac_rac := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec2 AND codigo = 'FRACCION_RACIONES_ACONCAGUA_S2' LIMIT 1);
SET @b_km_rec := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec2 AND codigo = 'KM_RECORRIDOS_ACONCAGUA_S2' LIMIT 1);
SET @b_km_total := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec2 AND codigo = 'KM_TOTAL_ACONCAGUA_S2' LIMIT 1);
SET @b_alimento := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec2 AND codigo = 'ALIMENTO_G_ACONCAGUA_S2' LIMIT 1);
SET @b_pers_rep := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec2 AND codigo = 'PERSONAS_REPARTO_ACONCAGUA_S2' LIMIT 1);
SET @b_racion := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec2 AND codigo = 'RACION_G_ACONCAGUA_S2' LIMIT 1);
SET @b_personas := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec2 AND codigo = 'PERSONAS_ACONCAGUA_S2' LIMIT 1);
SET @b_elementos := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec2 AND codigo = 'ELEMENTOS_ACONCAGUA_S2' LIMIT 1);
SET @b_capacidad := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec2 AND codigo = 'CAPACIDAD_CAJA_ACONCAGUA_S2' LIMIT 1);
SET @b_total_kg := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec2 AND codigo = 'TOTAL_ALIMENTO_KG_ACONCAGUA_S2' LIMIT 1);
SET @b_frac_e1 := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec2 AND codigo = 'FRACCION_ETAPA_1_ACONCAGUA_S2' LIMIT 1);
SET @b_frac_e2 := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec2 AND codigo = 'FRACCION_ETAPA_2_ACONCAGUA_S2' LIMIT 1);

INSERT INTO valores_banco_seccion (banco_valores_seccion_id, indice, valor, etiqueta, activo) VALUES
  (@b_total_rac, 1, 60, '60 raciones', 1), (@b_total_rac, 2, 120, '120 raciones', 1), (@b_total_rac, 3, 180, '180 raciones', 1), (@b_total_rac, 4, 240, '240 raciones', 1), (@b_total_rac, 5, 300, '300 raciones', 1), (@b_total_rac, 6, 360, '360 raciones', 1), (@b_total_rac, 7, 420, '420 raciones', 1), (@b_total_rac, 8, 480, '480 raciones', 1),
  (@b_frac_rac, 1, 1, '1/2', 1), (@b_frac_rac, 2, 2, '1/3', 1), (@b_frac_rac, 3, 3, '1/4', 1), (@b_frac_rac, 4, 4, '2/3', 1), (@b_frac_rac, 5, 5, '3/4', 1), (@b_frac_rac, 6, 6, '1/5', 1), (@b_frac_rac, 7, 7, '2/5', 1), (@b_frac_rac, 8, 8, '3/5', 1),
  (@b_km_rec, 1, 1, '1 km', 1), (@b_km_rec, 2, 2, '2 km', 1), (@b_km_rec, 3, 3, '3 km', 1), (@b_km_rec, 4, 4, '4 km', 1), (@b_km_rec, 5, 5, '5 km', 1), (@b_km_rec, 6, 6, '6 km', 1), (@b_km_rec, 7, 7, '7 km', 1), (@b_km_rec, 8, 8, '8 km', 1),
  (@b_km_total, 1, 10, '10 km', 1), (@b_km_total, 2, 12, '12 km', 1), (@b_km_total, 3, 16, '16 km', 1), (@b_km_total, 4, 20, '20 km', 1), (@b_km_total, 5, 25, '25 km', 1), (@b_km_total, 6, 40, '40 km', 1), (@b_km_total, 7, 50, '50 km', 1), (@b_km_total, 8, 100, '100 km', 1),
  (@b_alimento, 1, 1000, '1000 g', 1), (@b_alimento, 2, 2000, '2000 g', 1), (@b_alimento, 3, 3000, '3000 g', 1), (@b_alimento, 4, 4000, '4000 g', 1), (@b_alimento, 5, 5000, '5000 g', 1), (@b_alimento, 6, 6000, '6000 g', 1), (@b_alimento, 7, 7000, '7000 g', 1), (@b_alimento, 8, 8000, '8000 g', 1),
  (@b_pers_rep, 1, 2, '2', 1), (@b_pers_rep, 2, 4, '4', 1), (@b_pers_rep, 3, 5, '5', 1), (@b_pers_rep, 4, 8, '8', 1), (@b_pers_rep, 5, 10, '10', 1), (@b_pers_rep, 6, 20, '20', 1), (@b_pers_rep, 7, 25, '25', 1), (@b_pers_rep, 8, 40, '40', 1),
  (@b_racion, 1, 100, '100 g', 1), (@b_racion, 2, 125, '125 g', 1), (@b_racion, 3, 150, '150 g', 1), (@b_racion, 4, 175, '175 g', 1), (@b_racion, 5, 200, '200 g', 1), (@b_racion, 6, 225, '225 g', 1), (@b_racion, 7, 250, '250 g', 1), (@b_racion, 8, 300, '300 g', 1),
  (@b_personas, 1, 3, '3', 1), (@b_personas, 2, 4, '4', 1), (@b_personas, 3, 5, '5', 1), (@b_personas, 4, 6, '6', 1), (@b_personas, 5, 8, '8', 1), (@b_personas, 6, 10, '10', 1), (@b_personas, 7, 12, '12', 1), (@b_personas, 8, 15, '15', 1),
  (@b_elementos, 1, 43, '43', 1), (@b_elementos, 2, 58, '58', 1), (@b_elementos, 3, 76, '76', 1), (@b_elementos, 4, 91, '91', 1), (@b_elementos, 5, 125, '125', 1), (@b_elementos, 6, 148, '148', 1), (@b_elementos, 7, 173, '173', 1), (@b_elementos, 8, 219, '219', 1),
  (@b_capacidad, 1, 4, '4', 1), (@b_capacidad, 2, 5, '5', 1), (@b_capacidad, 3, 6, '6', 1), (@b_capacidad, 4, 8, '8', 1), (@b_capacidad, 5, 10, '10', 1), (@b_capacidad, 6, 12, '12', 1), (@b_capacidad, 7, 15, '15', 1), (@b_capacidad, 8, 20, '20', 1),
  (@b_total_kg, 1, 20, '20 kg', 1), (@b_total_kg, 2, 40, '40 kg', 1), (@b_total_kg, 3, 60, '60 kg', 1), (@b_total_kg, 4, 80, '80 kg', 1), (@b_total_kg, 5, 100, '100 kg', 1), (@b_total_kg, 6, 120, '120 kg', 1), (@b_total_kg, 7, 140, '140 kg', 1), (@b_total_kg, 8, 160, '160 kg', 1),
  (@b_frac_e1, 1, 1, '1/20', 1), (@b_frac_e1, 2, 2, '1/10', 1), (@b_frac_e1, 3, 3, '3/20', 1), (@b_frac_e1, 4, 4, '1/5', 1), (@b_frac_e1, 5, 5, '1/4', 1), (@b_frac_e1, 6, 6, '3/10', 1), (@b_frac_e1, 7, 7, '7/20', 1), (@b_frac_e1, 8, 8, '2/5', 1),
  (@b_frac_e2, 1, 1, '1/10', 1), (@b_frac_e2, 2, 2, '3/20', 1), (@b_frac_e2, 3, 3, '1/5', 1), (@b_frac_e2, 4, 4, '1/4', 1), (@b_frac_e2, 5, 5, '1/10', 1), (@b_frac_e2, 6, 6, '3/20', 1), (@b_frac_e2, 7, 7, '1/5', 1), (@b_frac_e2, 8, 8, '1/4', 1)
ON DUPLICATE KEY UPDATE valor = VALUES(valor), etiqueta = VALUES(etiqueta), activo = VALUES(activo);

INSERT INTO ejercicios (actividad_id, seccion_tp_id, codigo, consigna, explicacion, formula_respuesta, tolerancia, orden, activo) VALUES
  (@act2, @sec2, 'aconcagua-s2-ej01-preparacion-raciones', 'El equipo dispone de {TOTAL_RACIONES}. Para la primera etapa se utilizara {FRACCION} del total. Cuantas raciones se utilizaran?', 'Multiplique el total de raciones por la fraccion indicada.', 'TOTAL_RACIONES * FRACCION_EXACTA', 0, 10, 1),
  (@act2, @sec2, 'aconcagua-s2-ej02-raciones-disponibles', 'El equipo dispone de {TOTAL_RACIONES}. Durante una jornada consume {FRACCION} del total. Cuantas raciones quedan disponibles?', 'Calcule la parte consumida y restela al total inicial.', 'TOTAL_RACIONES - (TOTAL_RACIONES * FRACCION_EXACTA)', 0, 20, 1),
  (@act2, @sec2, 'aconcagua-s2-ej03-fraccion-recorrido', 'Durante una etapa, el equipo recorrio {KM_RECORRIDOS} de un trayecto total de {KM_TOTAL}. Exprese la parte recorrida como numero decimal redondeado a tres cifras decimales.', 'Divida los kilometros recorridos por los kilometros totales.', 'KM_RECORRIDOS / KM_TOTAL', 0.001, 30, 1),
  (@act2, @sec2, 'aconcagua-s2-ej04-reparto-alimentos', 'El equipo dispone de {ALIMENTO_G} de frutos secos para repartir en partes iguales entre {PERSONAS_REPARTO} integrantes. Cuantos gramos recibira cada persona?', 'Divida la cantidad total de alimento por la cantidad de integrantes.', 'ALIMENTO_G / PERSONAS_REPARTO', 0, 40, 1),
  (@act2, @sec2, 'aconcagua-s2-ej05-alimento-necesario', 'Cada integrante necesita una racion de {RACION_G} de alimento. Si participan {PERSONAS} integrantes, cuantos gramos se necesitan en total?', 'Multiplique la racion por integrante por la cantidad de integrantes.', 'RACION_G * PERSONAS', 0, 50, 1),
  (@act2, @sec2, 'aconcagua-s2-ej06-cajas-materiales', 'El equipo debe transportar {ELEMENTOS} elementos. En cada caja entran como maximo {CAPACIDAD_CAJA} elementos. Cual es la cantidad minima de cajas necesarias?', 'Divida los elementos por la capacidad y redondee hacia arriba. Una caja incompleta tambien cuenta.', 'CEIL(ELEMENTOS / CAPACIDAD_CAJA)', 0, 60, 1),
  (@act2, @sec2, 'aconcagua-s2-ej07-porcentaje-trayecto', 'El equipo recorrio {KM_RECORRIDOS} de un trayecto total de {KM_TOTAL}. Que porcentaje del trayecto completo? Redondee a una cifra decimal.', 'Divida los kilometros recorridos por el total y multiplique por 100.', '(KM_RECORRIDOS / KM_TOTAL) * 100', 0.1, 70, 1),
  (@act2, @sec2, 'aconcagua-s2-ej08-control-provisiones', 'El equipo comenzo la expedicion con {TOTAL_ALIMENTO_KG} de alimento. Durante la primera etapa consumio {FRACCION_ETAPA_1} del total inicial y durante la segunda etapa consumio {FRACCION_ETAPA_2} del total inicial. Cuantos kilogramos de alimento quedan?', 'Sume las fracciones consumidas, reste ese consumo del total inicial y calcule el alimento restante.', 'TOTAL_ALIMENTO_KG * (1 - FRACCION_ETAPA_1_EXACTA - FRACCION_ETAPA_2_EXACTA)', 0, 80, 1)
ON DUPLICATE KEY UPDATE actividad_id = VALUES(actividad_id), seccion_tp_id = VALUES(seccion_tp_id), consigna = VALUES(consigna), explicacion = VALUES(explicacion), formula_respuesta = VALUES(formula_respuesta), tolerancia = VALUES(tolerancia), orden = VALUES(orden), activo = VALUES(activo);

UPDATE ejercicios
SET activo = 0
WHERE actividad_id = @act2
  AND codigo NOT IN (
    'aconcagua-s2-ej01-preparacion-raciones',
    'aconcagua-s2-ej02-raciones-disponibles',
    'aconcagua-s2-ej03-fraccion-recorrido',
    'aconcagua-s2-ej04-reparto-alimentos',
    'aconcagua-s2-ej05-alimento-necesario',
    'aconcagua-s2-ej06-cajas-materiales',
    'aconcagua-s2-ej07-porcentaje-trayecto',
    'aconcagua-s2-ej08-control-provisiones'
  );

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_rac, @u_rac, @b_total_rac, 'TOTAL_RACIONES', 'TOTAL_RACIONES', 'Total de raciones asignado desde banco Aconcagua S2.', 10 FROM ejercicios e WHERE e.codigo IN ('aconcagua-s2-ej01-preparacion-raciones', 'aconcagua-s2-ej02-raciones-disponibles')
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_frac, @u_frac, @b_frac_rac, 'FRACCION', 'FRACCION', 'Fraccion asignada desde banco Aconcagua S2.', 20 FROM ejercicios e WHERE e.codigo IN ('aconcagua-s2-ej01-preparacion-raciones', 'aconcagua-s2-ej02-raciones-disponibles')
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_dist, @u_km, @b_km_rec, 'KM_RECORRIDOS', 'KM_RECORRIDOS', 'Kilometros recorridos asignados desde banco Aconcagua S2.', 10 FROM ejercicios e WHERE e.codigo IN ('aconcagua-s2-ej03-fraccion-recorrido', 'aconcagua-s2-ej07-porcentaje-trayecto')
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_dist, @u_km, @b_km_total, 'KM_TOTAL', 'KM_TOTAL', 'Kilometros totales asignados desde banco Aconcagua S2.', 20 FROM ejercicios e WHERE e.codigo IN ('aconcagua-s2-ej03-fraccion-recorrido', 'aconcagua-s2-ej07-porcentaje-trayecto')
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_g, @u_g, @b_alimento, 'ALIMENTO_G', 'ALIMENTO_G', 'Alimento asignado desde banco Aconcagua S2.', 10 FROM ejercicios e WHERE e.codigo = 'aconcagua-s2-ej04-reparto-alimentos'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_pers, @u_pers, @b_pers_rep, 'PERSONAS_REPARTO', 'PERSONAS_REPARTO', 'Personas asignadas desde banco Aconcagua S2.', 20 FROM ejercicios e WHERE e.codigo = 'aconcagua-s2-ej04-reparto-alimentos'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_g, @u_g, @b_racion, 'RACION_G', 'RACION_G', 'Racion por integrante asignada desde banco Aconcagua S2.', 10 FROM ejercicios e WHERE e.codigo = 'aconcagua-s2-ej05-alimento-necesario'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_pers, @u_pers, @b_personas, 'PERSONAS', 'PERSONAS', 'Personas asignadas desde banco Aconcagua S2.', 20 FROM ejercicios e WHERE e.codigo = 'aconcagua-s2-ej05-alimento-necesario'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_elem, @u_elem, @b_elementos, 'ELEMENTOS', 'ELEMENTOS', 'Elementos asignados desde banco Aconcagua S2.', 10 FROM ejercicios e WHERE e.codigo = 'aconcagua-s2-ej06-cajas-materiales'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_elem, @u_elem, @b_capacidad, 'CAPACIDAD_CAJA', 'CAPACIDAD_CAJA', 'Capacidad de caja asignada desde banco Aconcagua S2.', 20 FROM ejercicios e WHERE e.codigo = 'aconcagua-s2-ej06-cajas-materiales'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_kg, @u_kg, @b_total_kg, 'TOTAL_ALIMENTO_KG', 'TOTAL_ALIMENTO_KG', 'Alimento inicial asignado desde banco Aconcagua S2.', 10 FROM ejercicios e WHERE e.codigo = 'aconcagua-s2-ej08-control-provisiones'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_frac, @u_frac, @b_frac_e1, 'FRACCION_ETAPA_1', 'FRACCION_ETAPA_1', 'Fraccion de consumo de primera etapa.', 20 FROM ejercicios e WHERE e.codigo = 'aconcagua-s2-ej08-control-provisiones'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_frac, @u_frac, @b_frac_e2, 'FRACCION_ETAPA_2', 'FRACCION_ETAPA_2', 'Fraccion de consumo de segunda etapa.', 30 FROM ejercicios e WHERE e.codigo = 'aconcagua-s2-ej08-control-provisiones'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

UPDATE combinaciones_ejercicio ce
INNER JOIN ejercicios e ON e.id = ce.ejercicio_id
SET ce.activa = 0
WHERE e.actividad_id = @act2;

COMMIT;
