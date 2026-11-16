USE electrodesafio;

START TRANSACTION;

INSERT INTO cursos (id, nombre, especialidad, turno, ciclo_lectivo, activo) VALUES
  (101, 'Electrotecnia 1', 'Electrotecnia', NULL, 2026, 1)
ON DUPLICATE KEY UPDATE
  especialidad = VALUES(especialidad),
  turno = VALUES(turno),
  activo = VALUES(activo);

INSERT INTO alumnos (dni, nombre, fecha_nacimiento) VALUES
  ('90000003', 'Alumno de ejemplo 03', '2010-01-01'),
  ('90000004', 'Alumno de ejemplo 04', '2010-01-01'),
  ('90000005', 'Alumno de ejemplo 05', '2010-01-01'),
  ('90000006', 'Alumno de ejemplo 06', '2010-01-01'),
  ('90000007', 'Alumno de ejemplo 07', '2010-01-01'),
  ('90000008', 'Alumno de ejemplo 08', '2010-01-01'),
  ('90000009', 'Alumno de ejemplo 09', '2010-01-01'),
  ('90000010', 'Alumno de ejemplo 10', '2010-01-01'),
  ('90000011', 'Alumno de ejemplo 11', '2010-01-01'),
  ('90000012', 'Alumno de ejemplo 12', '2010-01-01'),
  ('90000013', 'Alumno de ejemplo 13', '2010-01-01'),
  ('90000014', 'Alumno de ejemplo 14', '2010-01-01'),
  ('90000015', 'Alumno de ejemplo 15', '2010-01-01'),
  ('90000016', 'Alumno de ejemplo 16', '2010-01-01'),
  ('90000017', 'Alumno de ejemplo 17', '2010-01-01'),
  ('90000018', 'Alumno de ejemplo 18', '2010-01-01'),
  ('90000019', 'Alumno de ejemplo 19', '2010-01-01'),
  ('90000020', 'Alumno de ejemplo 20', '2010-01-01')
ON DUPLICATE KEY UPDATE
  nombre = VALUES(nombre),
  fecha_nacimiento = VALUES(fecha_nacimiento);

INSERT INTO inscripciones (alumno_id, curso_id, fecha_alta, activo)
SELECT a.id, 101, CURRENT_DATE, 1
FROM alumnos a
WHERE a.dni IN (
  '90000003', '90000004', '90000005', '90000006', '90000007', '90000008',
  '90000009', '90000010', '90000011', '90000012', '90000013', '90000014',
  '90000015', '90000016', '90000017', '90000018', '90000019', '90000020'
)
ON DUPLICATE KEY UPDATE activo = VALUES(activo);

INSERT INTO temas (nombre, descripcion, orden, activo) VALUES
  ('Ley de Ohm', 'Relacion entre tension, corriente y resistencia.', 20, 1)
ON DUPLICATE KEY UPDATE
  descripcion = VALUES(descripcion),
  orden = VALUES(orden),
  activo = VALUES(activo);

SET @tema_ley_ohm := (SELECT id FROM temas WHERE nombre = 'Ley de Ohm' LIMIT 1);

INSERT INTO contenedores_actividad (tema_id, nombre, descripcion, orden, activo) VALUES
  (@tema_ley_ohm, 'TP 5', 'Actividades del Trabajo Practico 5.', 50, 1)
ON DUPLICATE KEY UPDATE
  descripcion = VALUES(descripcion),
  orden = VALUES(orden),
  activo = VALUES(activo);

SET @contenedor_tp5 := (
  SELECT id FROM contenedores_actividad
  WHERE tema_id = @tema_ley_ohm AND nombre = 'TP 5'
  LIMIT 1
);

INSERT INTO trabajos_practicos (tema_id, titulo, descripcion, codigo, activo) VALUES
  (@tema_ley_ohm, 'Trabajo Practico N 5 - Ley de Ohm', 'TP de Ley de Ohm dividido en tres secciones de trabajo en clase.', 'tp5-ley-ohm-2026', 1)
ON DUPLICATE KEY UPDATE
  tema_id = VALUES(tema_id),
  titulo = VALUES(titulo),
  descripcion = VALUES(descripcion),
  activo = VALUES(activo);

SET @tp5 := (
  SELECT id FROM trabajos_practicos
  WHERE codigo = 'tp5-ley-ohm-2026'
  LIMIT 1
);

INSERT INTO secciones_tp (trabajo_practico_id, titulo, descripcion, orden, activo) VALUES
  (@tp5, 'Seccion 1 - Interpretacion, medicion y corriente', 'Ejercicios 1 al 10: lectura de circuitos, instrumentos y calculo de corriente.', 10, 1),
  (@tp5, 'Seccion 2 - Calculo de voltaje', 'Ejercicios 11 al 13: calculo de tension con corriente y resistencia.', 20, 1),
  (@tp5, 'Seccion 3 - Calculo de resistencia', 'Ejercicios 14 al 16: calculo de resistencia con tension y corriente.', 30, 1)
ON DUPLICATE KEY UPDATE
  titulo = VALUES(titulo),
  descripcion = VALUES(descripcion),
  activo = VALUES(activo);

SET @sec1 := (SELECT id FROM secciones_tp WHERE trabajo_practico_id = @tp5 AND orden = 10 LIMIT 1);
SET @sec2 := (SELECT id FROM secciones_tp WHERE trabajo_practico_id = @tp5 AND orden = 20 LIMIT 1);
SET @sec3 := (SELECT id FROM secciones_tp WHERE trabajo_practico_id = @tp5 AND orden = 30 LIMIT 1);

INSERT INTO actividades (contenedor_id, seccion_tp_id, titulo, descripcion, nivel, puntos, estado, visible_alumno, acceso_habilitado, puntaje_habilitado, icono, orden)
SELECT @contenedor_tp5, @sec1, 'TP5 - Seccion 1', 'Interpretacion de circuitos, instrumentos y calculo de corriente.', 'Inicial', 10, 'Disponible', 1, 1, 0, 'I', 10
WHERE NOT EXISTS (SELECT 1 FROM actividades WHERE seccion_tp_id = @sec1 AND titulo = 'TP5 - Seccion 1');

INSERT INTO actividades (contenedor_id, seccion_tp_id, titulo, descripcion, nivel, puntos, estado, visible_alumno, acceso_habilitado, puntaje_habilitado, icono, orden)
SELECT @contenedor_tp5, @sec2, 'TP5 - Seccion 2', 'Calculo de voltaje aplicando Ley de Ohm.', 'Inicial', 10, 'Disponible', 1, 1, 0, 'V', 20
WHERE NOT EXISTS (SELECT 1 FROM actividades WHERE seccion_tp_id = @sec2 AND titulo = 'TP5 - Seccion 2');

INSERT INTO actividades (contenedor_id, seccion_tp_id, titulo, descripcion, nivel, puntos, estado, visible_alumno, acceso_habilitado, puntaje_habilitado, icono, orden)
SELECT @contenedor_tp5, @sec3, 'TP5 - Seccion 3', 'Calculo de resistencia aplicando Ley de Ohm.', 'Inicial', 10, 'Disponible', 1, 1, 0, 'R', 30
WHERE NOT EXISTS (SELECT 1 FROM actividades WHERE seccion_tp_id = @sec3 AND titulo = 'TP5 - Seccion 3');

SET @act1 := (SELECT id FROM actividades WHERE seccion_tp_id = @sec1 AND titulo = 'TP5 - Seccion 1' LIMIT 1);
SET @act2 := (SELECT id FROM actividades WHERE seccion_tp_id = @sec2 AND titulo = 'TP5 - Seccion 2' LIMIT 1);
SET @act3 := (SELECT id FROM actividades WHERE seccion_tp_id = @sec3 AND titulo = 'TP5 - Seccion 3' LIMIT 1);

INSERT INTO ejercicios (actividad_id, seccion_tp_id, codigo, consigna, explicacion, formula_respuesta, tolerancia, orden, activo) VALUES
  (@act1, @sec1, 'tp5-ej01-corriente-circuitos', 'Observar tres circuitos con V y R. Determinar la corriente de cada circuito e identificar mayor y menor corriente.', 'Se aplica I = V / R y se comparan los resultados.', 'V / R', 0.01, 10, 1),
  (@act1, @sec1, 'tp5-ej02-resistencia-circuitos', 'Observar tres circuitos con V e I. Determinar la resistencia conectada en cada circuito.', 'Se aplica R = V / I cuidando las unidades de corriente.', 'V / I', 0.01, 20, 1),
  (@act1, @sec1, 'tp5-ej03-voltaje-circuitos', 'Observar tres circuitos con R e I. Determinar la tension de alimentacion necesaria.', 'Se aplica V = I x R cuidando prefijos como k, M, m y micro.', 'I * R', 0.01, 30, 1),
  (@act1, @sec1, 'tp5-ej04-instrumentos', 'Dibujar circuitos con amperimetro y voltimetro, indicar conexion serie/paralelo y calcular lecturas.', 'El amperimetro se conecta en serie y el voltimetro en paralelo.', NULL, NULL, 40, 1),
  (@act1, @sec1, 'tp5-ej05-corriente-basica', 'Determinar corriente para distintos valores de tension y resistencia.', 'Se aplica I = V / R.', 'V / R', 0.01, 50, 1),
  (@act1, @sec1, 'tp5-ej06-corriente-prefijos', 'Determinar corriente con valores que incluyen kV, kohm y Mohm.', 'Se convierten unidades y se aplica I = V / R.', 'V / R', 0.01, 60, 1),
  (@act1, @sec1, 'tp5-ej07-corriente-bateria', 'Calcular la corriente de un resistor de 10 ohm conectado a una bateria de 12 V.', 'I = 12 V / 10 ohm.', 'V / R', 0.01, 70, 1),
  (@act1, @sec1, 'tp5-ej08-colores-tolerancia', 'Interpretar codigo de colores naranja, naranja, rojo, oro y calcular corriente maxima y minima con 12 V.', 'Se obtiene el valor nominal y tolerancia del resistor, luego I = V / R.', 'V / R', 0.01, 80, 1),
  (@act1, @sec1, 'tp5-ej09-colores-corriente', 'Interpretar codigo amarillo, violeta, naranja, plata y calcular la corriente con fuente de 25 V.', 'Se obtiene la resistencia por codigo de colores y luego I = V / R.', 'V / R', 0.01, 90, 1),
  (@act1, @sec1, 'tp5-ej10-aplicacion-corriente', 'Resolver situaciones practicas de corriente y expresar resultados en A, mA o microA.', 'Se aplica I = V / R y se expresa en la unidad pedida.', 'V / R', 0.01, 100, 1),
  (@act2, @sec2, 'tp5-ej11-voltaje-basico', 'Calcular voltaje para distintos valores de corriente y resistencia.', 'Se aplica V = I x R.', 'I * R', 0.01, 10, 1),
  (@act2, @sec2, 'tp5-ej12-voltaje-prefijos', 'Calcular voltaje con valores de corriente y resistencia usando mA, microA, kohm y Mohm.', 'Se convierten unidades y se aplica V = I x R.', 'I * R', 0.01, 20, 1),
  (@act2, @sec2, 'tp5-ej13-aplicacion-voltaje', 'Resolver situaciones practicas de tension medida o aplicada en resistores.', 'Se aplica V = I x R y se interpreta la lectura del voltimetro.', 'I * R', 0.01, 30, 1),
  (@act3, @sec3, 'tp5-ej14-resistencia-basica', 'Encontrar resistencia para distintos valores de tension y corriente.', 'Se aplica R = V / I.', 'V / I', 0.01, 10, 1),
  (@act3, @sec3, 'tp5-ej15-resistencia-prefijos', 'Calcular resistencia con tension y corriente usando kV, mA y microA.', 'Se convierten unidades y se aplica R = V / I.', 'V / I', 0.01, 20, 1),
  (@act3, @sec3, 'tp5-ej16-aplicacion-resistencia', 'Resolver situaciones practicas de resistencia y expresar resultados en ohm o kohm.', 'Se aplica R = V / I y se expresa en la unidad solicitada.', 'V / I', 0.01, 30, 1)
ON DUPLICATE KEY UPDATE
  actividad_id = VALUES(actividad_id),
  seccion_tp_id = VALUES(seccion_tp_id),
  consigna = VALUES(consigna),
  explicacion = VALUES(explicacion),
  formula_respuesta = VALUES(formula_respuesta),
  tolerancia = VALUES(tolerancia),
  orden = VALUES(orden),
  activo = VALUES(activo);

COMMIT;
