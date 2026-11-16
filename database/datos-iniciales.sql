USE electrodesafio;

INSERT INTO docentes (id, nombre, email) VALUES
  (1, 'Profesor Electrotecnia', NULL)
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), email = VALUES(email);

INSERT INTO materias (id, nombre, slug, activo) VALUES
  (1, 'Electrotecnia I', 'electrotecnia-i', 1),
  (2, 'Electrotecnia II', 'electrotecnia-ii', 1)
ON DUPLICATE KEY UPDATE
  nombre = VALUES(nombre),
  slug = VALUES(slug),
  activo = VALUES(activo);

INSERT INTO cursos (id, materia_id, anio, division, nombre, especialidad, turno, ciclo_lectivo, activo) VALUES
  (1, 2, 4, '1', '4 1 - Electrotecnia II', 'Electrotecnia', 'Manana', 2026, 1),
  (2, 2, 4, '3', '4 3 - Electrotecnia II', 'Electrotecnia', 'Manana', 2026, 1),
  (101, 1, 3, '1', '3 1 - Electrotecnia I', 'Electrotecnia', 'Manana', 2026, 1)
ON DUPLICATE KEY UPDATE
  materia_id = VALUES(materia_id),
  anio = VALUES(anio),
  division = VALUES(division),
  nombre = VALUES(nombre),
  especialidad = VALUES(especialidad),
  turno = VALUES(turno),
  activo = VALUES(activo);

INSERT INTO alumnos (id, dni, nombre, fecha_nacimiento) VALUES
  (1, '90000001', 'Alumno de ejemplo 01', '2010-01-01'),
  (2, '90000002', 'Alumno de ejemplo 02', '2010-01-01')
ON DUPLICATE KEY UPDATE
  dni = VALUES(dni),
  nombre = VALUES(nombre),
  fecha_nacimiento = VALUES(fecha_nacimiento);

INSERT INTO inscripciones (id, alumno_id, curso_id, fecha_alta, activo) VALUES
  (1, 1, 1, '2026-03-01', 1),
  (2, 2, 1, '2026-03-01', 1)
ON DUPLICATE KEY UPDATE activo = VALUES(activo);

INSERT INTO tipos_calificacion (id, nombre, descripcion, activo) VALUES
  (1, 'Trabajo practico', 'Actividad practica individual o grupal.', 1),
  (2, 'Evaluacion escrita', 'Instancia escrita con calificacion numerica.', 1),
  (3, 'Leccion oral', 'Defensa o explicacion oral.', 1),
  (4, 'Integrador', 'Actividad integradora de varios temas.', 1),
  (5, 'Desafio', 'Puntaje o nota derivada de actividades de la plataforma.', 1)
ON DUPLICATE KEY UPDATE descripcion = VALUES(descripcion), activo = VALUES(activo);

INSERT INTO calificaciones (inscripcion_id, tipo_calificacion_id, titulo, nota, fecha, observacion) VALUES
  (1, 1, 'TP circuitos en serie', 8.50, '2026-05-10', 'Resuelve correctamente la equivalencia.'),
  (2, 1, 'TP circuitos en serie', 7.00, '2026-05-10', NULL);

INSERT INTO temas (id, nombre, descripcion, orden, activo) VALUES
  (1, 'Circuitos basicos', 'Resistencia, tension y corriente en circuitos simples.', 10, 1),
  (2, 'Ley de Ohm', 'Relacion entre tension, corriente y resistencia.', 20, 1),
  (3, 'Mediciones electricas', 'Uso de instrumentos y lectura de magnitudes.', 30, 1)
ON DUPLICATE KEY UPDATE
  descripcion = VALUES(descripcion),
  orden = VALUES(orden),
  activo = VALUES(activo);

INSERT INTO trabajos_practicos (id, tema_id, titulo, descripcion, codigo, activo) VALUES
  (1, 1, 'TP 01 - Circuitos en serie', 'Trabajo practico dividido en secciones para resistencias en serie.', 'tp-circuitos-serie-01', 1),
  (2, 2, 'TP 02 - Ley de Ohm', 'Trabajo practico dividido en secciones para Ley de Ohm.', 'tp-ley-ohm-02', 1)
ON DUPLICATE KEY UPDATE
  tema_id = VALUES(tema_id),
  titulo = VALUES(titulo),
  descripcion = VALUES(descripcion),
  activo = VALUES(activo);

INSERT INTO secciones_tp (id, trabajo_practico_id, titulo, descripcion, orden, activo) VALUES
  (1, 1, 'Seccion 1 - Resistencia equivalente', 'Ejercicios de suma de resistencias en serie.', 10, 1),
  (2, 1, 'Seccion 2 - Corriente en serie', 'Ejercicios de corriente usando tension y resistencia total.', 20, 1),
  (3, 1, 'Seccion 3 - Problemas combinados', 'Ejercicios mixtos de circuitos en serie.', 30, 1),
  (4, 2, 'Seccion 1 - Despeje de resistencia', 'Calculo de resistencia con V e I.', 10, 1),
  (5, 2, 'Seccion 2 - Despeje de tension', 'Calculo de tension con I y R.', 20, 1),
  (6, 2, 'Seccion 3 - Despeje de corriente', 'Calculo de corriente con V y R.', 30, 1)
ON DUPLICATE KEY UPDATE
  titulo = VALUES(titulo),
  descripcion = VALUES(descripcion),
  activo = VALUES(activo);

INSERT INTO contenedores_actividad (id, tema_id, nombre, descripcion, orden, activo) VALUES
  (1, 1, 'Acceso 1', 'Primer bloque de desafios de circuitos basicos.', 10, 1),
  (2, 1, 'Acceso 2', 'Segundo bloque con ejercicios combinados.', 20, 1),
  (3, 2, 'Acceso 1', 'Desafios introductorios de Ley de Ohm.', 10, 1),
  (4, 3, 'Acceso 1', 'Practicas de lectura de instrumentos.', 10, 1)
ON DUPLICATE KEY UPDATE
  descripcion = VALUES(descripcion),
  orden = VALUES(orden),
  activo = VALUES(activo);

INSERT INTO actividades (id, contenedor_id, seccion_tp_id, titulo, descripcion, nivel, puntos, estado, visible_alumno, acceso_habilitado, puntaje_habilitado, icono, orden) VALUES
  (1, 1, 1, 'Circuitos en serie', 'Tension, corriente y resistencia en accion.', 'Inicial', 10, 'Oculta', 0, 0, 0, '*', 10),
  (2, 3, 4, 'Ley de Ohm', 'Resolve calculos para encender el tablero.', 'Intermedio', 10, 'Oculta', 0, 0, 0, 'R', 10),
  (3, 4, NULL, 'Mediciones reales', 'Lecturas de multimetro y diagnostico.', 'Avanzado', 15, 'Oculta', 0, 0, 0, '*', 10)
ON DUPLICATE KEY UPDATE
  contenedor_id = VALUES(contenedor_id),
  seccion_tp_id = VALUES(seccion_tp_id),
  titulo = VALUES(titulo),
  descripcion = VALUES(descripcion),
  nivel = VALUES(nivel),
  puntos = VALUES(puntos),
  estado = VALUES(estado),
  visible_alumno = VALUES(visible_alumno),
  acceso_habilitado = VALUES(acceso_habilitado),
  puntaje_habilitado = VALUES(puntaje_habilitado),
  icono = VALUES(icono),
  orden = VALUES(orden);

INSERT INTO magnitudes (id, nombre, simbolo) VALUES
  (1, 'Resistencia', 'R'),
  (2, 'Tension', 'V'),
  (3, 'Corriente', 'I'),
  (4, 'Capacitancia', 'C'),
  (5, 'Inductancia', 'L'),
  (6, 'Angulo', 'ANG')
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), simbolo = VALUES(simbolo);

INSERT INTO unidades (id, magnitud_id, nombre, simbolo, factor_base) VALUES
  (1, 1, 'ohm', 'ohm', 1),
  (2, 2, 'volt', 'V', 1),
  (3, 3, 'ampere', 'A', 1),
  (4, 4, 'faradio', 'F', 1),
  (5, 4, 'microfaradio', 'uF', 0.000001),
  (6, 5, 'henrio', 'H', 1),
  (7, 5, 'milihenrio', 'mH', 0.001),
  (8, 6, 'grado', 'deg', 1)
ON DUPLICATE KEY UPDATE
  magnitud_id = VALUES(magnitud_id),
  nombre = VALUES(nombre),
  simbolo = VALUES(simbolo),
  factor_base = VALUES(factor_base);

INSERT INTO ejercicios (id, actividad_id, seccion_tp_id, codigo, consigna, explicacion, formula_respuesta, tolerancia, orden, activo) VALUES
  (1, 1, 1, 'serie-req-2r', 'Cual es la resistencia equivalente del circuito con R1 = {{R1}} ohm y R2 = {{R2}} ohm?', 'En serie, las resistencias se suman: Req = R1 + R2.', 'R1 + R2', 0.01, 10, 1),
  (2, 1, 2, 'serie-corriente-v-r', 'Si una bateria entrega {{V}} V y la resistencia total es {{R}} ohm, cual es la corriente?', 'Aplicamos I = V / R.', 'V / R', 0.01, 20, 1),
  (3, 1, 3, 'serie-req-mixta', 'Dos resistencias de {{R1}} ohm y {{R2}} ohm estan en serie. Cuanto vale Req?', 'En una conexion en serie las resistencias se suman.', 'R1 + R2', 0.01, 30, 1),
  (4, 2, 4, 'ohm-resistencia', 'Con V = {{V}} V e I = {{I}} A, cual es la resistencia?', 'Por Ley de Ohm, R = V / I.', 'V / I', 0.01, 10, 1),
  (5, 2, 5, 'ohm-tension', 'Con R = {{R}} ohm e I = {{I}} A, que tension hay?', 'Por Ley de Ohm, V = I x R.', 'I * R', 0.01, 20, 1)
ON DUPLICATE KEY UPDATE
  actividad_id = VALUES(actividad_id),
  seccion_tp_id = VALUES(seccion_tp_id),
  codigo = VALUES(codigo),
  consigna = VALUES(consigna),
  explicacion = VALUES(explicacion),
  formula_respuesta = VALUES(formula_respuesta),
  tolerancia = VALUES(tolerancia),
  orden = VALUES(orden),
  activo = VALUES(activo);

INSERT INTO opciones_ejercicio (id, ejercicio_id, texto, es_correcta, orden) VALUES
  (1, 1, '6 ohm', 0, 10),
  (2, 1, '12 ohm', 1, 20),
  (3, 1, '18 ohm', 0, 30),
  (4, 1, '36 ohm', 0, 40),
  (5, 2, '0.5 A', 0, 10),
  (6, 2, '1 A', 0, 20),
  (7, 2, '2 A', 1, 30),
  (8, 2, '6 A', 0, 40),
  (9, 3, '4 ohm', 0, 10),
  (10, 3, '8 ohm', 0, 20),
  (11, 3, '12 ohm', 1, 30),
  (12, 3, '32 ohm', 0, 40),
  (13, 4, '2 ohm', 0, 10),
  (14, 4, '5 ohm', 1, 20),
  (15, 4, '8 ohm', 0, 30),
  (16, 4, '20 ohm', 0, 40),
  (17, 5, '7 V', 0, 10),
  (18, 5, '12 V', 1, 20),
  (19, 5, '16 V', 0, 30),
  (20, 5, '24 V', 0, 40)
ON DUPLICATE KEY UPDATE
  ejercicio_id = VALUES(ejercicio_id),
  texto = VALUES(texto),
  es_correcta = VALUES(es_correcta),
  orden = VALUES(orden);

INSERT INTO variables_ejercicio (id, ejercicio_id, magnitud_id, unidad_id, nombre, etiqueta, descripcion, orden) VALUES
  (1, 1, 1, 1, 'R1', 'R1', 'Primera resistencia del circuito serie.', 10),
  (2, 1, 1, 1, 'R2', 'R2', 'Segunda resistencia del circuito serie.', 20),
  (3, 2, 2, 2, 'V', 'V', 'Tension de fuente.', 10),
  (4, 2, 1, 1, 'R', 'R', 'Resistencia total.', 20),
  (5, 4, 2, 2, 'V', 'V', 'Tension aplicada.', 10),
  (6, 4, 3, 3, 'I', 'I', 'Corriente medida.', 20),
  (7, 5, 1, 1, 'R', 'R', 'Resistencia del circuito.', 10),
  (8, 5, 3, 3, 'I', 'I', 'Corriente del circuito.', 20)
ON DUPLICATE KEY UPDATE
  ejercicio_id = VALUES(ejercicio_id),
  magnitud_id = VALUES(magnitud_id),
  unidad_id = VALUES(unidad_id),
  etiqueta = VALUES(etiqueta),
  descripcion = VALUES(descripcion),
  orden = VALUES(orden);

INSERT INTO valores_variable (id, variable_ejercicio_id, valor, activo, orden) VALUES
  (1, 1, 4, 1, 10),
  (2, 1, 6, 1, 20),
  (3, 1, 8, 1, 30),
  (4, 2, 4, 1, 10),
  (5, 2, 6, 1, 20),
  (6, 2, 8, 1, 30),
  (7, 3, 6, 1, 10),
  (8, 3, 12, 1, 20),
  (9, 3, 24, 1, 30),
  (10, 4, 3, 1, 10),
  (11, 4, 6, 1, 20),
  (12, 4, 12, 1, 30),
  (13, 5, 10, 1, 10),
  (14, 5, 12, 1, 20),
  (15, 5, 24, 1, 30),
  (16, 6, 2, 1, 10),
  (17, 6, 3, 1, 20),
  (18, 6, 4, 1, 30),
  (19, 7, 3, 1, 10),
  (20, 7, 4, 1, 20),
  (21, 7, 6, 1, 30),
  (22, 8, 2, 1, 10),
  (23, 8, 3, 1, 20),
  (24, 8, 4, 1, 30)
ON DUPLICATE KEY UPDATE
  variable_ejercicio_id = VALUES(variable_ejercicio_id),
  valor = VALUES(valor),
  activo = VALUES(activo),
  orden = VALUES(orden);

INSERT INTO combinaciones_ejercicio (id, ejercicio_id, codigo_hash, respuesta_numero, respuesta_texto, usos, activa) VALUES
  (1, 1, SHA2('ej1:R1=4;R2=6', 256), 10, '10 ohm', 0, 1),
  (2, 1, SHA2('ej1:R1=6;R2=6', 256), 12, '12 ohm', 0, 1),
  (3, 1, SHA2('ej1:R1=8;R2=4', 256), 12, '12 ohm', 0, 1),
  (4, 2, SHA2('ej2:V=12;R=6', 256), 2, '2 A', 0, 1),
  (5, 2, SHA2('ej2:V=24;R=12', 256), 2, '2 A', 0, 1),
  (6, 4, SHA2('ej4:V=10;I=2', 256), 5, '5 ohm', 0, 1),
  (7, 4, SHA2('ej4:V=12;I=3', 256), 4, '4 ohm', 0, 1),
  (8, 5, SHA2('ej5:R=3;I=4', 256), 12, '12 V', 0, 1)
ON DUPLICATE KEY UPDATE
  respuesta_numero = VALUES(respuesta_numero),
  respuesta_texto = VALUES(respuesta_texto),
  activa = VALUES(activa);

INSERT INTO combinacion_valores (combinacion_ejercicio_id, variable_ejercicio_id, valor_variable_id, valor) VALUES
  (1, 1, 1, 4),
  (1, 2, 5, 6),
  (2, 1, 2, 6),
  (2, 2, 5, 6),
  (3, 1, 3, 8),
  (3, 2, 4, 4),
  (4, 3, 8, 12),
  (4, 4, 11, 6),
  (5, 3, 9, 24),
  (5, 4, 12, 12),
  (6, 5, 13, 10),
  (6, 6, 16, 2),
  (7, 5, 14, 12),
  (7, 6, 17, 3),
  (8, 7, 19, 3),
  (8, 8, 24, 4)
ON DUPLICATE KEY UPDATE
  valor_variable_id = VALUES(valor_variable_id),
  valor = VALUES(valor);

INSERT INTO valores_actividad (actividad_id, magnitud_id, unidad_id, etiqueta, valor, descripcion, orden) VALUES
  (1, 1, 1, 'R1 ejemplo', 6, 'Primera resistencia fija de referencia.', 10),
  (1, 1, 1, 'R2 ejemplo', 6, 'Segunda resistencia fija de referencia.', 20),
  (1, 2, 2, 'Vfuente ejemplo', 12, 'Tension de alimentacion de referencia.', 30),
  (2, 2, 2, 'V ejemplo', 10, 'Tension conocida de referencia.', 10),
  (2, 3, 3, 'I ejemplo', 2, 'Corriente conocida de referencia.', 20),
  (3, 1, 1, 'Rmedida ejemplo', 220, 'Resistencia de practica para medicion.', 10);
