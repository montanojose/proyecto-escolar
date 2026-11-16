USE electrodesafio;

START TRANSACTION;

INSERT INTO magnitudes (nombre, simbolo) VALUES
  ('Costo', 'COST'),
  ('Estacas', 'EST'),
  ('Personas', 'PERS'),
  ('Longitud', 'LONG'),
  ('Superficie', 'SUP'),
  ('Factor', 'FACTOR')
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), simbolo = VALUES(simbolo);

SET @mag_cost := (SELECT id FROM magnitudes WHERE simbolo = 'COST' LIMIT 1);
SET @mag_est := (SELECT id FROM magnitudes WHERE simbolo = 'EST' LIMIT 1);
SET @mag_pers := (SELECT id FROM magnitudes WHERE simbolo = 'PERS' LIMIT 1);
SET @mag_long := (SELECT id FROM magnitudes WHERE simbolo = 'LONG' LIMIT 1);
SET @mag_sup := (SELECT id FROM magnitudes WHERE simbolo = 'SUP' LIMIT 1);
SET @mag_factor := (SELECT id FROM magnitudes WHERE simbolo = 'FACTOR' LIMIT 1);

INSERT INTO unidades (magnitud_id, nombre, simbolo, factor_base) VALUES
  (@mag_cost, 'pesos', '$', 1),
  (@mag_est, 'estacas', 'estacas', 1),
  (@mag_pers, 'personas', 'personas', 1),
  (@mag_long, 'metros', 'm', 1),
  (@mag_sup, 'metros cuadrados', 'm2', 1),
  (@mag_factor, 'factor', '', 1)
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), factor_base = VALUES(factor_base);

SET @u_cost := (SELECT id FROM unidades WHERE magnitud_id = @mag_cost AND simbolo = '$' LIMIT 1);
SET @u_est := (SELECT id FROM unidades WHERE magnitud_id = @mag_est AND simbolo = 'estacas' LIMIT 1);
SET @u_pers := (SELECT id FROM unidades WHERE magnitud_id = @mag_pers AND simbolo = 'personas' LIMIT 1);
SET @u_m := (SELECT id FROM unidades WHERE magnitud_id = @mag_long AND simbolo = 'm' LIMIT 1);
SET @u_m2 := (SELECT id FROM unidades WHERE magnitud_id = @mag_sup AND simbolo = 'm2' LIMIT 1);
SET @u_factor := (SELECT id FROM unidades WHERE magnitud_id = @mag_factor AND simbolo = '' LIMIT 1);

SET @tema := (SELECT id FROM temas WHERE nombre = 'Mision Aconcagua' LIMIT 1);
SET @tp := (SELECT id FROM trabajos_practicos WHERE codigo = 'mision-aconcagua-2026' LIMIT 1);
SET @contenedor := (SELECT id FROM contenedores_actividad WHERE tema_id = @tema AND nombre = 'Mision Aconcagua' LIMIT 1);

INSERT INTO secciones_tp (trabajo_practico_id, titulo, descripcion, orden, activo) VALUES
  (@tp, 'Seccion 3 - Diseno del campamento', 'Relaciones entre variables, ecuaciones lineales, perimetro, superficie y teorema de Pitagoras.', 30, 1)
ON DUPLICATE KEY UPDATE titulo = VALUES(titulo), descripcion = VALUES(descripcion), activo = VALUES(activo);

SET @sec3 := (SELECT id FROM secciones_tp WHERE trabajo_practico_id = @tp AND orden = 30 LIMIT 1);

INSERT INTO actividades (contenedor_id, seccion_tp_id, titulo, descripcion, nivel, puntos, estado, visible_alumno, acceso_habilitado, puntaje_habilitado, icono, orden)
SELECT @contenedor, @sec3, 'Mision Aconcagua - Seccion 3', 'Mision Aconcagua: organizar un campamento cientifico. En la ultima etapa de la mision, el equipo debe calcular los costos del traslado y organizar correctamente el espacio del campamento. Seccion 3: diseno del campamento.', 'Inicial', 10, 'Disponible', 1, 1, 0, 'A', 90
WHERE NOT EXISTS (
  SELECT 1 FROM actividades WHERE seccion_tp_id = @sec3 AND titulo = 'Mision Aconcagua - Seccion 3'
);

SET @act3 := (SELECT id FROM actividades WHERE seccion_tp_id = @sec3 AND titulo = 'Mision Aconcagua - Seccion 3' LIMIT 1);

UPDATE actividades
SET contenedor_id = @contenedor,
    descripcion = 'Mision Aconcagua: organizar un campamento cientifico. En la ultima etapa de la mision, el equipo debe calcular los costos del traslado y organizar correctamente el espacio del campamento. Seccion 3: diseno del campamento.',
    nivel = 'Inicial',
    puntos = 10,
    estado = 'Disponible',
    visible_alumno = 1,
    acceso_habilitado = 1,
    puntaje_habilitado = 0,
    icono = 'A',
    orden = 90
WHERE id = @act3;

INSERT INTO bancos_valores_seccion (seccion_tp_id, magnitud_id, unidad_id, nombre, codigo, descripcion, orden, activo) VALUES
  (@sec3, @mag_cost, @u_cost, 'Costo fijo', 'COSTO_FIJO_ACONCAGUA_S3', 'Costo fijo del transporte.', 10, 1),
  (@sec3, @mag_cost, @u_cost, 'Costo por persona', 'COSTO_PERSONA_ACONCAGUA_S3', 'Costo por integrante.', 20, 1),
  (@sec3, @mag_pers, @u_pers, 'Personas transporte', 'PERSONAS_TRANSPORTE_ACONCAGUA_S3', 'Cantidad de personas que viajan.', 30, 1),
  (@sec3, @mag_est, @u_est, 'Estacas por carpa', 'ESTACAS_CARPA_ACONCAGUA_S3', 'Estacas necesarias por carpa.', 40, 1),
  (@sec3, @mag_pers, @u_pers, 'Cantidad de carpas', 'CANTIDAD_CARPAS_ACONCAGUA_S3', 'Cantidad de carpas a instalar.', 50, 1),
  (@sec3, @mag_est, @u_est, 'Estacas de reserva', 'ESTACAS_RESERVA_ACONCAGUA_S3', 'Estacas de reserva.', 60, 1),
  (@sec3, @mag_long, @u_m, 'Largo', 'LARGO_ACONCAGUA_S3', 'Largo del campamento.', 70, 1),
  (@sec3, @mag_long, @u_m, 'Ancho', 'ANCHO_ACONCAGUA_S3', 'Ancho del campamento.', 80, 1),
  (@sec3, @mag_factor, @u_factor, 'Factor de escala', 'FACTOR_ACONCAGUA_S3', 'Factor de escala para ternas pitagoricas.', 90, 1),
  (@sec3, @mag_long, @u_m, 'Cateto base A', 'CATETO_BASE_A_ACONCAGUA_S3', 'Cateto base A de terna pitagorica.', 100, 1),
  (@sec3, @mag_long, @u_m, 'Cateto base B', 'CATETO_BASE_B_ACONCAGUA_S3', 'Cateto base B de terna pitagorica.', 110, 1),
  (@sec3, @mag_long, @u_m, 'Hipotenusa base', 'HIPOTENUSA_BASE_ACONCAGUA_S3', 'Hipotenusa base de terna pitagorica.', 120, 1),
  (@sec3, @mag_pers, @u_pers, 'Cantidad de carpas superficie', 'CANTIDAD_CARPAS_SUP_ACONCAGUA_S3', 'Cantidad de carpas para superficie libre.', 130, 1),
  (@sec3, @mag_long, @u_m, 'Largo carpa', 'LARGO_CARPA_ACONCAGUA_S3', 'Largo de cada carpa.', 140, 1),
  (@sec3, @mag_long, @u_m, 'Ancho carpa', 'ANCHO_CARPA_ACONCAGUA_S3', 'Ancho de cada carpa.', 150, 1)
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), nombre = VALUES(nombre), descripcion = VALUES(descripcion), orden = VALUES(orden), activo = VALUES(activo);

SET @b_cf := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec3 AND codigo = 'COSTO_FIJO_ACONCAGUA_S3' LIMIT 1);
SET @b_cp := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec3 AND codigo = 'COSTO_PERSONA_ACONCAGUA_S3' LIMIT 1);
SET @b_pers := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec3 AND codigo = 'PERSONAS_TRANSPORTE_ACONCAGUA_S3' LIMIT 1);
SET @b_ec := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec3 AND codigo = 'ESTACAS_CARPA_ACONCAGUA_S3' LIMIT 1);
SET @b_car := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec3 AND codigo = 'CANTIDAD_CARPAS_ACONCAGUA_S3' LIMIT 1);
SET @b_er := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec3 AND codigo = 'ESTACAS_RESERVA_ACONCAGUA_S3' LIMIT 1);
SET @b_largo := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec3 AND codigo = 'LARGO_ACONCAGUA_S3' LIMIT 1);
SET @b_ancho := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec3 AND codigo = 'ANCHO_ACONCAGUA_S3' LIMIT 1);
SET @b_factor := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec3 AND codigo = 'FACTOR_ACONCAGUA_S3' LIMIT 1);
SET @b_cata := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec3 AND codigo = 'CATETO_BASE_A_ACONCAGUA_S3' LIMIT 1);
SET @b_catb := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec3 AND codigo = 'CATETO_BASE_B_ACONCAGUA_S3' LIMIT 1);
SET @b_hip := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec3 AND codigo = 'HIPOTENUSA_BASE_ACONCAGUA_S3' LIMIT 1);
SET @b_carsup := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec3 AND codigo = 'CANTIDAD_CARPAS_SUP_ACONCAGUA_S3' LIMIT 1);
SET @b_lcarpa := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec3 AND codigo = 'LARGO_CARPA_ACONCAGUA_S3' LIMIT 1);
SET @b_acarpa := (SELECT id FROM bancos_valores_seccion WHERE seccion_tp_id = @sec3 AND codigo = 'ANCHO_CARPA_ACONCAGUA_S3' LIMIT 1);

INSERT INTO valores_banco_seccion (banco_valores_seccion_id, indice, valor, etiqueta, activo) VALUES
  (@b_cf, 1, 5000, '5000 $', 1), (@b_cf, 2, 7500, '7500 $', 1), (@b_cf, 3, 10000, '10000 $', 1), (@b_cf, 4, 12500, '12500 $', 1), (@b_cf, 5, 15000, '15000 $', 1), (@b_cf, 6, 17500, '17500 $', 1), (@b_cf, 7, 20000, '20000 $', 1), (@b_cf, 8, 25000, '25000 $', 1),
  (@b_cp, 1, 1000, '1000 $', 1), (@b_cp, 2, 1250, '1250 $', 1), (@b_cp, 3, 1500, '1500 $', 1), (@b_cp, 4, 1750, '1750 $', 1), (@b_cp, 5, 2000, '2000 $', 1), (@b_cp, 6, 2250, '2250 $', 1), (@b_cp, 7, 2500, '2500 $', 1), (@b_cp, 8, 3000, '3000 $', 1),
  (@b_pers, 1, 4, '4 personas', 1), (@b_pers, 2, 5, '5 personas', 1), (@b_pers, 3, 6, '6 personas', 1), (@b_pers, 4, 8, '8 personas', 1), (@b_pers, 5, 10, '10 personas', 1), (@b_pers, 6, 12, '12 personas', 1), (@b_pers, 7, 15, '15 personas', 1), (@b_pers, 8, 20, '20 personas', 1),
  (@b_ec, 1, 4, '4', 1), (@b_ec, 2, 5, '5', 1), (@b_ec, 3, 6, '6', 1), (@b_ec, 4, 7, '7', 1), (@b_ec, 5, 8, '8', 1), (@b_ec, 6, 9, '9', 1), (@b_ec, 7, 10, '10', 1), (@b_ec, 8, 12, '12', 1),
  (@b_car, 1, 2, '2', 1), (@b_car, 2, 3, '3', 1), (@b_car, 3, 4, '4', 1), (@b_car, 4, 5, '5', 1), (@b_car, 5, 6, '6', 1), (@b_car, 6, 7, '7', 1), (@b_car, 7, 8, '8', 1), (@b_car, 8, 10, '10', 1),
  (@b_er, 1, 2, '2', 1), (@b_er, 2, 4, '4', 1), (@b_er, 3, 5, '5', 1), (@b_er, 4, 6, '6', 1), (@b_er, 5, 8, '8', 1), (@b_er, 6, 10, '10', 1), (@b_er, 7, 12, '12', 1), (@b_er, 8, 15, '15', 1),
  (@b_largo, 1, 20, '20 m', 1), (@b_largo, 2, 24, '24 m', 1), (@b_largo, 3, 28, '28 m', 1), (@b_largo, 4, 30, '30 m', 1), (@b_largo, 5, 32, '32 m', 1), (@b_largo, 6, 36, '36 m', 1), (@b_largo, 7, 40, '40 m', 1), (@b_largo, 8, 48, '48 m', 1),
  (@b_ancho, 1, 10, '10 m', 1), (@b_ancho, 2, 12, '12 m', 1), (@b_ancho, 3, 14, '14 m', 1), (@b_ancho, 4, 15, '15 m', 1), (@b_ancho, 5, 16, '16 m', 1), (@b_ancho, 6, 18, '18 m', 1), (@b_ancho, 7, 20, '20 m', 1), (@b_ancho, 8, 24, '24 m', 1),
  (@b_factor, 1, 1, '1', 1), (@b_factor, 2, 2, '2', 1), (@b_factor, 3, 3, '3', 1), (@b_factor, 4, 4, '4', 1), (@b_factor, 5, 5, '5', 1), (@b_factor, 6, 6, '6', 1), (@b_factor, 7, 7, '7', 1), (@b_factor, 8, 8, '8', 1),
  (@b_cata, 1, 3, '3 m', 1), (@b_cata, 2, 5, '5 m', 1), (@b_cata, 3, 8, '8 m', 1), (@b_cata, 4, 7, '7 m', 1), (@b_cata, 5, 20, '20 m', 1), (@b_cata, 6, 12, '12 m', 1), (@b_cata, 7, 9, '9 m', 1), (@b_cata, 8, 28, '28 m', 1),
  (@b_catb, 1, 4, '4 m', 1), (@b_catb, 2, 12, '12 m', 1), (@b_catb, 3, 15, '15 m', 1), (@b_catb, 4, 24, '24 m', 1), (@b_catb, 5, 21, '21 m', 1), (@b_catb, 6, 35, '35 m', 1), (@b_catb, 7, 40, '40 m', 1), (@b_catb, 8, 45, '45 m', 1),
  (@b_hip, 1, 5, '5 m', 1), (@b_hip, 2, 13, '13 m', 1), (@b_hip, 3, 17, '17 m', 1), (@b_hip, 4, 25, '25 m', 1), (@b_hip, 5, 29, '29 m', 1), (@b_hip, 6, 37, '37 m', 1), (@b_hip, 7, 41, '41 m', 1), (@b_hip, 8, 53, '53 m', 1),
  (@b_carsup, 1, 1, '2', 1), (@b_carsup, 2, 2, '3', 1), (@b_carsup, 3, 3, '4', 1), (@b_carsup, 4, 4, '4', 1), (@b_carsup, 5, 5, '5', 1), (@b_carsup, 6, 6, '5', 1), (@b_carsup, 7, 7, '6', 1), (@b_carsup, 8, 8, '8', 1),
  (@b_lcarpa, 1, 1, '2 m', 1), (@b_lcarpa, 2, 2, '2 m', 1), (@b_lcarpa, 3, 3, '2 m', 1), (@b_lcarpa, 4, 4, '3 m', 1), (@b_lcarpa, 5, 5, '3 m', 1), (@b_lcarpa, 6, 6, '3 m', 1), (@b_lcarpa, 7, 7, '3 m', 1), (@b_lcarpa, 8, 8, '3 m', 1),
  (@b_acarpa, 1, 1, '2 m', 1), (@b_acarpa, 2, 2, '3 m', 1), (@b_acarpa, 3, 3, '3 m', 1), (@b_acarpa, 4, 4, '3 m', 1), (@b_acarpa, 5, 5, '3 m', 1), (@b_acarpa, 6, 6, '4 m', 1), (@b_acarpa, 7, 7, '4 m', 1), (@b_acarpa, 8, 8, '4 m', 1)
ON DUPLICATE KEY UPDATE valor = VALUES(valor), etiqueta = VALUES(etiqueta), activo = VALUES(activo);

INSERT INTO ejercicios (actividad_id, seccion_tp_id, codigo, consigna, explicacion, formula_respuesta, tolerancia, orden, activo) VALUES
  (@act3, @sec3, 'aconcagua-s3-ej01-costo-transporte', 'La empresa de transporte cobra un costo fijo de {COSTO_FIJO} y {COSTO_PERSONA} por cada integrante. Si viajan {PERSONAS}, cual sera el costo total?', 'Sume el costo fijo mas el costo por persona multiplicado por la cantidad de integrantes.', 'COSTO_FIJO + COSTO_PERSONA * PERSONAS', 0, 10, 1),
  (@act3, @sec3, 'aconcagua-s3-ej02-organizacion-carpas', 'Para instalar las carpas se necesitan {ESTACAS_CARPA} por cada carpa y se llevan {ESTACAS_RESERVA} de reserva. Si se instalaran {CANTIDAD_CARPAS} carpas, cuantas estacas deben transportarse?', 'Multiplique las estacas por carpa por la cantidad de carpas y sume la reserva.', 'ESTACAS_CARPA * CANTIDAD_CARPAS + ESTACAS_RESERVA', 0, 20, 1),
  (@act3, @sec3, 'aconcagua-s3-ej03-cantidad-integrantes', 'Una empresa cobra {COSTO_FIJO} de costo fijo y {COSTO_PERSONA} por cada integrante. El costo total del viaje fue de {COSTO_TOTAL}. Cuantas personas viajaron?', 'Reste el costo fijo al costo total y divida por el costo por persona.', '(COSTO_TOTAL - COSTO_FIJO) / COSTO_PERSONA', 0, 30, 1),
  (@act3, @sec3, 'aconcagua-s3-ej04-cerco-campamento', 'El campamento ocupara una zona rectangular de {LARGO} de largo y {ANCHO} de ancho. Cuantos metros de cuerda se necesitan para rodear completamente la zona?', 'Calcule el perimetro del rectangulo: dos veces la suma del largo y el ancho.', '2 * (LARGO + ANCHO)', 0, 40, 1),
  (@act3, @sec3, 'aconcagua-s3-ej05-superficie-campamento', 'Una zona rectangular destinada al campamento mide {LARGO} de largo y {ANCHO} de ancho. Cual es su superficie?', 'Multiplique el largo por el ancho.', 'LARGO * ANCHO', 0, 50, 1),
  (@act3, @sec3, 'aconcagua-s3-ej06-ancho-zona', 'Una zona rectangular tiene un perimetro de {PERIMETRO} y un largo de {LARGO}. Cuantos metros mide su ancho?', 'Divida el perimetro por dos y reste el largo.', 'PERIMETRO / 2 - LARGO', 0, 60, 1),
  (@act3, @sec3, 'aconcagua-s3-ej07-cable-diagonal', 'Para colocar un cable entre dos extremos del campamento se forma un triangulo rectangulo. Sus catetos miden {CATETO_A} y {CATETO_B}. Cuantos metros debe medir el cable?', 'Use la terna pitagorica escalada para obtener la hipotenusa.', 'HIPOTENUSA_BASE * FACTOR', 0, 70, 1),
  (@act3, @sec3, 'aconcagua-s3-ej08-superficie-libre', 'El campamento tiene una superficie rectangular de {LARGO} por {ANCHO}. En su interior se instalaran {CANTIDAD_CARPAS} carpas. Cada carpa ocupa {LARGO_CARPA} por {ANCHO_CARPA}. Cuantos metros cuadrados quedaran libres?', 'Calcule la superficie total y reste la superficie ocupada por todas las carpas.', 'LARGO * ANCHO - CANTIDAD_CARPAS * LARGO_CARPA * ANCHO_CARPA', 0, 80, 1)
ON DUPLICATE KEY UPDATE actividad_id = VALUES(actividad_id), seccion_tp_id = VALUES(seccion_tp_id), consigna = VALUES(consigna), explicacion = VALUES(explicacion), formula_respuesta = VALUES(formula_respuesta), tolerancia = VALUES(tolerancia), orden = VALUES(orden), activo = VALUES(activo);

UPDATE ejercicios
SET activo = 0
WHERE actividad_id = @act3
  AND codigo NOT IN (
    'aconcagua-s3-ej01-costo-transporte',
    'aconcagua-s3-ej02-organizacion-carpas',
    'aconcagua-s3-ej03-cantidad-integrantes',
    'aconcagua-s3-ej04-cerco-campamento',
    'aconcagua-s3-ej05-superficie-campamento',
    'aconcagua-s3-ej06-ancho-zona',
    'aconcagua-s3-ej07-cable-diagonal',
    'aconcagua-s3-ej08-superficie-libre'
  );

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_cost, @u_cost, @b_cf, 'COSTO_FIJO', 'COSTO_FIJO', 'Costo fijo asignado desde banco Aconcagua S3.', 10 FROM ejercicios e WHERE e.codigo IN ('aconcagua-s3-ej01-costo-transporte', 'aconcagua-s3-ej03-cantidad-integrantes')
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);
INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_cost, @u_cost, @b_cp, 'COSTO_PERSONA', 'COSTO_PERSONA', 'Costo por persona asignado desde banco Aconcagua S3.', 20 FROM ejercicios e WHERE e.codigo IN ('aconcagua-s3-ej01-costo-transporte', 'aconcagua-s3-ej03-cantidad-integrantes')
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);
INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_pers, @u_pers, @b_pers, 'PERSONAS', 'PERSONAS', 'Personas asignadas desde banco Aconcagua S3.', 30 FROM ejercicios e WHERE e.codigo IN ('aconcagua-s3-ej01-costo-transporte', 'aconcagua-s3-ej03-cantidad-integrantes')
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_est, @u_est, @b_ec, 'ESTACAS_CARPA', 'ESTACAS_CARPA', 'Estacas por carpa asignadas desde banco Aconcagua S3.', 10 FROM ejercicios e WHERE e.codigo = 'aconcagua-s3-ej02-organizacion-carpas'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);
INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_pers, @u_pers, @b_car, 'CANTIDAD_CARPAS', 'CANTIDAD_CARPAS', 'Cantidad de carpas asignada desde banco Aconcagua S3.', 20 FROM ejercicios e WHERE e.codigo = 'aconcagua-s3-ej02-organizacion-carpas'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);
INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_est, @u_est, @b_er, 'ESTACAS_RESERVA', 'ESTACAS_RESERVA', 'Estacas de reserva asignadas desde banco Aconcagua S3.', 30 FROM ejercicios e WHERE e.codigo = 'aconcagua-s3-ej02-organizacion-carpas'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_long, @u_m, @b_largo, 'LARGO', 'LARGO', 'Largo asignado desde banco Aconcagua S3.', 10 FROM ejercicios e WHERE e.codigo IN ('aconcagua-s3-ej04-cerco-campamento', 'aconcagua-s3-ej05-superficie-campamento', 'aconcagua-s3-ej06-ancho-zona', 'aconcagua-s3-ej08-superficie-libre')
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);
INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_long, @u_m, @b_ancho, 'ANCHO', 'ANCHO', 'Ancho asignado desde banco Aconcagua S3.', 20 FROM ejercicios e WHERE e.codigo IN ('aconcagua-s3-ej04-cerco-campamento', 'aconcagua-s3-ej05-superficie-campamento', 'aconcagua-s3-ej06-ancho-zona', 'aconcagua-s3-ej08-superficie-libre')
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_factor, @u_factor, @b_factor, 'FACTOR', 'FACTOR', 'Factor de escala asignado desde banco Aconcagua S3.', 10 FROM ejercicios e WHERE e.codigo = 'aconcagua-s3-ej07-cable-diagonal'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);
INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_long, @u_m, @b_cata, 'CATETO_BASE_A', 'CATETO_BASE_A', 'Cateto base A asignado desde banco Aconcagua S3.', 20 FROM ejercicios e WHERE e.codigo = 'aconcagua-s3-ej07-cable-diagonal'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);
INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_long, @u_m, @b_catb, 'CATETO_BASE_B', 'CATETO_BASE_B', 'Cateto base B asignado desde banco Aconcagua S3.', 30 FROM ejercicios e WHERE e.codigo = 'aconcagua-s3-ej07-cable-diagonal'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);
INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_long, @u_m, @b_hip, 'HIPOTENUSA_BASE', 'HIPOTENUSA_BASE', 'Hipotenusa base asignada desde banco Aconcagua S3.', 40 FROM ejercicios e WHERE e.codigo = 'aconcagua-s3-ej07-cable-diagonal'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_pers, @u_pers, @b_carsup, 'CANTIDAD_CARPAS', 'CANTIDAD_CARPAS', 'Cantidad de carpas para superficie libre asignada desde banco Aconcagua S3.', 30 FROM ejercicios e WHERE e.codigo = 'aconcagua-s3-ej08-superficie-libre'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);
INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_long, @u_m, @b_lcarpa, 'LARGO_CARPA', 'LARGO_CARPA', 'Largo de carpa asignado desde banco Aconcagua S3.', 40 FROM ejercicios e WHERE e.codigo = 'aconcagua-s3-ej08-superficie-libre'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);
INSERT INTO variables_ejercicio (ejercicio_id, magnitud_id, unidad_id, banco_valores_seccion_id, nombre, etiqueta, descripcion, orden)
SELECT e.id, @mag_long, @u_m, @b_acarpa, 'ANCHO_CARPA', 'ANCHO_CARPA', 'Ancho de carpa asignado desde banco Aconcagua S3.', 50 FROM ejercicios e WHERE e.codigo = 'aconcagua-s3-ej08-superficie-libre'
ON DUPLICATE KEY UPDATE magnitud_id = VALUES(magnitud_id), unidad_id = VALUES(unidad_id), banco_valores_seccion_id = VALUES(banco_valores_seccion_id), etiqueta = VALUES(etiqueta), descripcion = VALUES(descripcion), orden = VALUES(orden);

UPDATE combinaciones_ejercicio ce
INNER JOIN ejercicios e ON e.id = ce.ejercicio_id
SET ce.activa = 0
WHERE e.actividad_id = @act3;

COMMIT;
