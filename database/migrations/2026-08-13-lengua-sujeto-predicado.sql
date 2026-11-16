USE electrodesafio;
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO temas (nombre, descripcion, orden, activo) VALUES
  ('Lengua', 'Actividades de Lengua para primer año de secundaria.', 5, 1)
ON DUPLICATE KEY UPDATE descripcion = VALUES(descripcion), orden = VALUES(orden), activo = VALUES(activo);

SET @tema_lengua := (SELECT id FROM temas WHERE nombre = 'Lengua' LIMIT 1);

INSERT INTO contenedores_actividad (tema_id, nombre, descripcion, orden, activo) VALUES
  (@tema_lengua, 'Primer año', 'Actividades de Lengua para primer año de secundaria.', 10, 1)
ON DUPLICATE KEY UPDATE descripcion = VALUES(descripcion), orden = VALUES(orden), activo = VALUES(activo);

SET @contenedor_lengua := (
  SELECT id FROM contenedores_actividad
  WHERE tema_id = @tema_lengua AND nombre = 'Primer año'
  LIMIT 1
);

INSERT INTO actividades (contenedor_id, seccion_tp_id, titulo, descripcion, nivel, puntos, estado, visible_alumno, acceso_habilitado, puntaje_habilitado, icono, orden)
SELECT @contenedor_lengua, NULL, 'Reconocemos el sujeto y el predicado',
       'Leé atentamente la oración y seleccioná sujeto, predicado, núcleo del sujeto y verbo.',
       'Primer año', 10, 'Disponible', 1, 1, 0, 'L', 10
WHERE NOT EXISTS (
  SELECT 1 FROM actividades
  WHERE contenedor_id = @contenedor_lengua AND titulo = 'Reconocemos el sujeto y el predicado'
);

UPDATE actividades
SET descripcion = 'Leé atentamente la oración y seleccioná sujeto, predicado, núcleo del sujeto y verbo.',
    nivel = 'Primer año',
    estado = 'Disponible',
    visible_alumno = 1,
    acceso_habilitado = 1,
    puntaje_habilitado = 0,
    icono = 'L',
    orden = 10
WHERE contenedor_id = @contenedor_lengua
  AND titulo = 'Reconocemos el sujeto y el predicado';

CREATE TABLE IF NOT EXISTS lengua_oraciones (
  id INT UNSIGNED PRIMARY KEY,
  texto VARCHAR(180) NOT NULL,
  palabras_json TEXT NOT NULL,
  respuesta_json TEXT NOT NULL,
  activa TINYINT(1) NOT NULL DEFAULT 1,
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS lengua_progreso (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  alumno_id INT UNSIGNED NOT NULL,
  actividad_id INT UNSIGNED NOT NULL,
  intento_id INT UNSIGNED NULL,
  oracion_id INT UNSIGNED NOT NULL,
  paso_actual VARCHAR(30) NOT NULL DEFAULT 'sujeto',
  respuestas_json TEXT NOT NULL,
  intentos_json TEXT NOT NULL,
  completada TINYINT(1) NOT NULL DEFAULT 0,
  iniciado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ultimo_acceso_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  finalizado_en DATETIME NULL,
  UNIQUE KEY uq_lengua_alumno_actividad (alumno_id, actividad_id),
  CONSTRAINT fk_lengua_progreso_alumno FOREIGN KEY (alumno_id) REFERENCES alumnos(id) ON DELETE CASCADE,
  CONSTRAINT fk_lengua_progreso_actividad FOREIGN KEY (actividad_id) REFERENCES actividades(id) ON DELETE CASCADE,
  CONSTRAINT fk_lengua_progreso_intento FOREIGN KEY (intento_id) REFERENCES intentos(id) ON DELETE SET NULL,
  CONSTRAINT fk_lengua_progreso_oracion FOREIGN KEY (oracion_id) REFERENCES lengua_oraciones(id) ON DELETE RESTRICT,
  INDEX idx_lengua_progreso_oracion (actividad_id, oracion_id),
  INDEX idx_lengua_progreso_estado (actividad_id, completada, paso_actual)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS lengua_asignaciones (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  alumno_id INT UNSIGNED NOT NULL,
  actividad_id INT UNSIGNED NOT NULL,
  intento_id INT UNSIGNED NULL,
  oracion_id INT UNSIGNED NOT NULL,
  asignado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_lengua_asignaciones_alumno FOREIGN KEY (alumno_id) REFERENCES alumnos(id) ON DELETE CASCADE,
  CONSTRAINT fk_lengua_asignaciones_actividad FOREIGN KEY (actividad_id) REFERENCES actividades(id) ON DELETE CASCADE,
  CONSTRAINT fk_lengua_asignaciones_intento FOREIGN KEY (intento_id) REFERENCES intentos(id) ON DELETE SET NULL,
  CONSTRAINT fk_lengua_asignaciones_oracion FOREIGN KEY (oracion_id) REFERENCES lengua_oraciones(id) ON DELETE RESTRICT,
  UNIQUE KEY uq_lengua_asignacion_intento (intento_id),
  INDEX idx_lengua_asignaciones_alumno (alumno_id, actividad_id, oracion_id),
  INDEX idx_lengua_asignaciones_oracion (actividad_id, oracion_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO lengua_oraciones (id, texto, palabras_json, respuesta_json, activa) VALUES
(1, 'La maestra explicó la consigna.', '["La","maestra","explicó","la","consigna"]', '{"sujeto":[0,1],"predicado":[2,3,4],"nucleo_sujeto":[1],"verbo":[2]}', 1),
(2, 'El perro duerme junto a la puerta.', '["El","perro","duerme","junto","a","la","puerta"]', '{"sujeto":[0,1],"predicado":[2,3,4,5,6],"nucleo_sujeto":[1],"verbo":[2]}', 1),
(3, 'Los estudiantes completaron la actividad.', '["Los","estudiantes","completaron","la","actividad"]', '{"sujeto":[0,1],"predicado":[2,3,4],"nucleo_sujeto":[1],"verbo":[2]}', 1),
(4, 'Mi hermano arregló la bicicleta.', '["Mi","hermano","arregló","la","bicicleta"]', '{"sujeto":[0,1],"predicado":[2,3,4],"nucleo_sujeto":[1],"verbo":[2]}', 1),
(5, 'La computadora guarda los archivos.', '["La","computadora","guarda","los","archivos"]', '{"sujeto":[0,1],"predicado":[2,3,4],"nucleo_sujeto":[1],"verbo":[2]}', 1),
(6, 'El fuerte viento movió las ramas.', '["El","fuerte","viento","movió","las","ramas"]', '{"sujeto":[0,1,2],"predicado":[3,4,5],"nucleo_sujeto":[2],"verbo":[3]}', 1),
(7, 'Nuestra profesora corrigió los trabajos.', '["Nuestra","profesora","corrigió","los","trabajos"]', '{"sujeto":[0,1],"predicado":[2,3,4],"nucleo_sujeto":[1],"verbo":[2]}', 1),
(8, 'El tren llegó a la estación.', '["El","tren","llegó","a","la","estación"]', '{"sujeto":[0,1],"predicado":[2,3,4,5],"nucleo_sujeto":[1],"verbo":[2]}', 1),
(9, 'La intensa lluvia mojó el patio.', '["La","intensa","lluvia","mojó","el","patio"]', '{"sujeto":[0,1,2],"predicado":[3,4,5],"nucleo_sujeto":[2],"verbo":[3]}', 1),
(10, 'Un electricista revisó la instalación.', '["Un","electricista","revisó","la","instalación"]', '{"sujeto":[0,1],"predicado":[2,3,4],"nucleo_sujeto":[1],"verbo":[2]}', 1),
(11, 'El pequeño robot detectó la línea.', '["El","pequeño","robot","detectó","la","línea"]', '{"sujeto":[0,1,2],"predicado":[3,4,5],"nucleo_sujeto":[2],"verbo":[3]}', 1),
(12, 'La batería nueva alimenta el circuito.', '["La","batería","nueva","alimenta","el","circuito"]', '{"sujeto":[0,1,2],"predicado":[3,4,5],"nucleo_sujeto":[1],"verbo":[3]}', 1),
(13, 'El sensor midió la temperatura.', '["El","sensor","midió","la","temperatura"]', '{"sujeto":[0,1],"predicado":[2,3,4],"nucleo_sujeto":[1],"verbo":[2]}', 1),
(14, 'Una potente turbina produce energía eléctrica.', '["Una","potente","turbina","produce","energía","eléctrica"]', '{"sujeto":[0,1,2],"predicado":[3,4,5],"nucleo_sujeto":[2],"verbo":[3]}', 1),
(15, 'El motor mueve las ruedas.', '["El","motor","mueve","las","ruedas"]', '{"sujeto":[0,1],"predicado":[2,3,4],"nucleo_sujeto":[1],"verbo":[2]}', 1),
(16, 'La directora presentó el proyecto.', '["La","directora","presentó","el","proyecto"]', '{"sujeto":[0,1],"predicado":[2,3,4],"nucleo_sujeto":[1],"verbo":[2]}', 1),
(17, 'El grupo construyó el prototipo.', '["El","grupo","construyó","el","prototipo"]', '{"sujeto":[0,1],"predicado":[2,3,4],"nucleo_sujeto":[1],"verbo":[2]}', 1),
(18, 'Mi compañera dibujó el esquema.', '["Mi","compañera","dibujó","el","esquema"]', '{"sujeto":[0,1],"predicado":[2,3,4],"nucleo_sujeto":[1],"verbo":[2]}', 1),
(19, 'La biblioteca escolar recibió nuevos libros.', '["La","biblioteca","escolar","recibió","nuevos","libros"]', '{"sujeto":[0,1,2],"predicado":[3,4,5],"nucleo_sujeto":[1],"verbo":[3]}', 1),
(20, 'El cocinero preparó la cena.', '["El","cocinero","preparó","la","cena"]', '{"sujeto":[0,1],"predicado":[2,3,4],"nucleo_sujeto":[1],"verbo":[2]}', 1),
(21, 'El jardinero regó las plantas.', '["El","jardinero","regó","las","plantas"]', '{"sujeto":[0,1],"predicado":[2,3,4],"nucleo_sujeto":[1],"verbo":[2]}', 1),
(22, 'La ambulancia cruzó la avenida.', '["La","ambulancia","cruzó","la","avenida"]', '{"sujeto":[0,1],"predicado":[2,3,4],"nucleo_sujeto":[1],"verbo":[2]}', 1),
(23, 'El joven músico afinó la guitarra.', '["El","joven","músico","afinó","la","guitarra"]', '{"sujeto":[0,1,2],"predicado":[3,4,5],"nucleo_sujeto":[2],"verbo":[3]}', 1),
(24, 'La médica atendió al paciente.', '["La","médica","atendió","al","paciente"]', '{"sujeto":[0,1],"predicado":[2,3,4],"nucleo_sujeto":[1],"verbo":[2]}', 1),
(25, 'Una familia mendocina visitó el museo.', '["Una","familia","mendocina","visitó","el","museo"]', '{"sujeto":[0,1,2],"predicado":[3,4,5],"nucleo_sujeto":[1],"verbo":[3]}', 1),
(26, 'El sol iluminó las montañas.', '["El","sol","iluminó","las","montañas"]', '{"sujeto":[0,1],"predicado":[2,3,4],"nucleo_sujeto":[1],"verbo":[2]}', 1),
(27, 'La luna llena apareció entre las nubes.', '["La","luna","llena","apareció","entre","las","nubes"]', '{"sujeto":[0,1,2],"predicado":[3,4,5,6],"nucleo_sujeto":[1],"verbo":[3]}', 1),
(28, 'El carpintero fabricó una mesa.', '["El","carpintero","fabricó","una","mesa"]', '{"sujeto":[0,1],"predicado":[2,3,4],"nucleo_sujeto":[1],"verbo":[2]}', 1),
(29, 'La impresora nueva imprimió el documento.', '["La","impresora","nueva","imprimió","el","documento"]', '{"sujeto":[0,1,2],"predicado":[3,4,5],"nucleo_sujeto":[1],"verbo":[3]}', 1),
(30, 'El teléfono recibió un mensaje.', '["El","teléfono","recibió","un","mensaje"]', '{"sujeto":[0,1],"predicado":[2,3,4],"nucleo_sujeto":[1],"verbo":[2]}', 1),
(31, 'La estudiante resolvió el problema.', '["La","estudiante","resolvió","el","problema"]', '{"sujeto":[0,1],"predicado":[2,3,4],"nucleo_sujeto":[1],"verbo":[2]}', 1),
(32, 'Nuestro equipo ganó el partido.', '["Nuestro","equipo","ganó","el","partido"]', '{"sujeto":[0,1],"predicado":[2,3,4],"nucleo_sujeto":[1],"verbo":[2]}', 1),
(33, 'El científico observó la muestra.', '["El","científico","observó","la","muestra"]', '{"sujeto":[0,1],"predicado":[2,3,4],"nucleo_sujeto":[1],"verbo":[2]}', 1),
(34, 'La pequeña abeja recorrió el jardín.', '["La","pequeña","abeja","recorrió","el","jardín"]', '{"sujeto":[0,1,2],"predicado":[3,4,5],"nucleo_sujeto":[2],"verbo":[3]}', 1),
(35, 'El camión transportó la mercadería.', '["El","camión","transportó","la","mercadería"]', '{"sujeto":[0,1],"predicado":[2,3,4],"nucleo_sujeto":[1],"verbo":[2]}', 1),
(36, 'La lámpara ilumina el escritorio.', '["La","lámpara","ilumina","el","escritorio"]', '{"sujeto":[0,1],"predicado":[2,3,4],"nucleo_sujeto":[1],"verbo":[2]}', 1),
(37, 'El técnico conectó los cables.', '["El","técnico","conectó","los","cables"]', '{"sujeto":[0,1],"predicado":[2,3,4],"nucleo_sujeto":[1],"verbo":[2]}', 1),
(38, 'La escuela organizó la exposición.', '["La","escuela","organizó","la","exposición"]', '{"sujeto":[0,1],"predicado":[2,3,4],"nucleo_sujeto":[1],"verbo":[2]}', 1),
(39, 'El fotógrafo tomó una imagen.', '["El","fotógrafo","tomó","una","imagen"]', '{"sujeto":[0,1],"predicado":[2,3,4],"nucleo_sujeto":[1],"verbo":[2]}', 1),
(40, 'El agua llenó el recipiente.', '["El","agua","llenó","el","recipiente"]', '{"sujeto":[0,1],"predicado":[2,3,4],"nucleo_sujeto":[1],"verbo":[2]}', 1)
ON DUPLICATE KEY UPDATE
  texto = VALUES(texto),
  palabras_json = VALUES(palabras_json),
  respuesta_json = VALUES(respuesta_json),
  activa = VALUES(activa);

SET @actividad_lengua_ok := (
  SELECT a.id
  FROM actividades a
  INNER JOIN contenedores_actividad ca ON ca.id = a.contenedor_id
  WHERE ca.tema_id = @tema_lengua
    AND ca.nombre = 'Primer año'
    AND a.titulo = 'Reconocemos el sujeto y el predicado'
  LIMIT 1
);

SET @actividad_lengua_mojibake := (
  SELECT a.id
  FROM actividades a
  INNER JOIN contenedores_actividad ca ON ca.id = a.contenedor_id
  WHERE ca.tema_id = @tema_lengua
    AND HEX(ca.nombre) = '5072696D65722061E2949CE296926F'
    AND a.titulo = 'Reconocemos el sujeto y el predicado'
  LIMIT 1
);

UPDATE lengua_progreso
SET actividad_id = @actividad_lengua_ok
WHERE @actividad_lengua_ok IS NOT NULL
  AND @actividad_lengua_mojibake IS NOT NULL
  AND actividad_id = @actividad_lengua_mojibake;

UPDATE intentos
SET actividad_id = @actividad_lengua_ok
WHERE @actividad_lengua_ok IS NOT NULL
  AND @actividad_lengua_mojibake IS NOT NULL
  AND actividad_id = @actividad_lengua_mojibake;

UPDATE movimientos_puntos
SET actividad_id = @actividad_lengua_ok
WHERE @actividad_lengua_ok IS NOT NULL
  AND @actividad_lengua_mojibake IS NOT NULL
  AND actividad_id = @actividad_lengua_mojibake;

DELETE FROM actividades
WHERE @actividad_lengua_ok IS NOT NULL
  AND @actividad_lengua_mojibake IS NOT NULL
  AND id = @actividad_lengua_mojibake;

DELETE ca
FROM contenedores_actividad ca
LEFT JOIN actividades a ON a.contenedor_id = ca.id
WHERE ca.tema_id = @tema_lengua
  AND HEX(ca.nombre) = '5072696D65722061E2949CE296926F'
  AND a.id IS NULL;

INSERT INTO lengua_asignaciones (alumno_id, actividad_id, intento_id, oracion_id, asignado_en)
SELECT lp.alumno_id, lp.actividad_id, lp.intento_id, lp.oracion_id, lp.iniciado_en
FROM lengua_progreso lp
WHERE lp.intento_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1
    FROM lengua_asignaciones la
    WHERE la.intento_id = lp.intento_id
  );
