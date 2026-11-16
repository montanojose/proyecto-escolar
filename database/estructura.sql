CREATE DATABASE IF NOT EXISTS electrodesafio
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE electrodesafio;

CREATE TABLE IF NOT EXISTS docentes (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(120) NOT NULL,
  email VARCHAR(160) NULL UNIQUE,
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS materias (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(80) NOT NULL UNIQUE,
  slug VARCHAR(80) NOT NULL UNIQUE,
  activo TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS cursos (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  materia_id INT UNSIGNED NULL,
  anio TINYINT UNSIGNED NULL,
  division VARCHAR(10) NULL,
  nombre VARCHAR(80) NOT NULL,
  especialidad VARCHAR(120) NULL,
  turno VARCHAR(40) NULL,
  ciclo_lectivo SMALLINT UNSIGNED NOT NULL,
  activo TINYINT(1) NOT NULL DEFAULT 1,
  UNIQUE KEY uq_curso_ciclo (nombre, ciclo_lectivo),
  CONSTRAINT fk_cursos_materia
    FOREIGN KEY (materia_id) REFERENCES materias(id)
    ON DELETE RESTRICT,
  INDEX idx_cursos_materia (materia_id),
  INDEX idx_cursos_ciclo_materia (ciclo_lectivo, materia_id, anio, division)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS alumnos (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  dni VARCHAR(10) NOT NULL UNIQUE,
  nombre VARCHAR(120) NOT NULL,
  fecha_nacimiento DATE NULL,
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS inscripciones (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  alumno_id INT UNSIGNED NOT NULL,
  curso_id INT UNSIGNED NOT NULL,
  fecha_alta DATE NOT NULL,
  activo TINYINT(1) NOT NULL DEFAULT 1,
  UNIQUE KEY uq_inscripcion_alumno_curso (alumno_id, curso_id),
  CONSTRAINT fk_inscripciones_alumno
    FOREIGN KEY (alumno_id) REFERENCES alumnos(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_inscripciones_curso
    FOREIGN KEY (curso_id) REFERENCES cursos(id)
    ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tipos_calificacion (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(80) NOT NULL UNIQUE,
  descripcion VARCHAR(180) NULL,
  activo TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS calificaciones (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  inscripcion_id INT UNSIGNED NOT NULL,
  tipo_calificacion_id INT UNSIGNED NOT NULL,
  titulo VARCHAR(140) NOT NULL,
  nota DECIMAL(4,2) NOT NULL,
  fecha DATE NOT NULL,
  observacion TEXT NULL,
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_calificaciones_inscripcion
    FOREIGN KEY (inscripcion_id) REFERENCES inscripciones(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_calificaciones_tipo
    FOREIGN KEY (tipo_calificacion_id) REFERENCES tipos_calificacion(id)
    ON DELETE RESTRICT,
  CONSTRAINT chk_calificacion_nota CHECK (nota >= 0 AND nota <= 10)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS temas (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(120) NOT NULL UNIQUE,
  descripcion TEXT NULL,
  orden INT UNSIGNED NOT NULL DEFAULT 100,
  activo TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trabajos_practicos (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tema_id INT UNSIGNED NOT NULL,
  titulo VARCHAR(140) NOT NULL,
  descripcion TEXT NULL,
  codigo VARCHAR(80) NOT NULL UNIQUE,
  activo TINYINT(1) NOT NULL DEFAULT 1,
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_trabajos_practicos_tema
    FOREIGN KEY (tema_id) REFERENCES temas(id)
    ON DELETE RESTRICT,
  INDEX idx_tp_tema (tema_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS secciones_tp (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  trabajo_practico_id INT UNSIGNED NOT NULL,
  titulo VARCHAR(140) NOT NULL,
  descripcion TEXT NULL,
  orden INT UNSIGNED NOT NULL DEFAULT 100,
  activo TINYINT(1) NOT NULL DEFAULT 1,
  UNIQUE KEY uq_seccion_tp_orden (trabajo_practico_id, orden),
  CONSTRAINT fk_secciones_tp
    FOREIGN KEY (trabajo_practico_id) REFERENCES trabajos_practicos(id)
    ON DELETE CASCADE,
  INDEX idx_secciones_tp (trabajo_practico_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS contenedores_actividad (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tema_id INT UNSIGNED NOT NULL,
  nombre VARCHAR(120) NOT NULL,
  descripcion TEXT NULL,
  orden INT UNSIGNED NOT NULL DEFAULT 100,
  activo TINYINT(1) NOT NULL DEFAULT 1,
  UNIQUE KEY uq_contenedor_tema_nombre (tema_id, nombre),
  CONSTRAINT fk_contenedores_tema
    FOREIGN KEY (tema_id) REFERENCES temas(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS actividades (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  contenedor_id INT UNSIGNED NOT NULL,
  seccion_tp_id INT UNSIGNED NULL,
  titulo VARCHAR(120) NOT NULL,
  descripcion TEXT NOT NULL,
  nivel VARCHAR(40) NOT NULL,
  puntos INT UNSIGNED NOT NULL DEFAULT 10,
  estado VARCHAR(40) NOT NULL DEFAULT 'Disponible',
  visible_alumno TINYINT(1) NOT NULL DEFAULT 1,
  acceso_habilitado TINYINT(1) NOT NULL DEFAULT 1,
  puntaje_habilitado TINYINT(1) NOT NULL DEFAULT 1,
  icono VARCHAR(16) NOT NULL DEFAULT '⚡',
  orden INT UNSIGNED NOT NULL DEFAULT 100,
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_actividades_contenedor
    FOREIGN KEY (contenedor_id) REFERENCES contenedores_actividad(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_actividades_seccion_tp
    FOREIGN KEY (seccion_tp_id) REFERENCES secciones_tp(id)
    ON DELETE SET NULL,
  INDEX idx_actividades_contenedor (contenedor_id),
  INDEX idx_actividades_seccion_tp (seccion_tp_id),
  INDEX idx_actividades_estado (visible_alumno, acceso_habilitado, puntaje_habilitado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS magnitudes (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(80) NOT NULL UNIQUE,
  simbolo VARCHAR(20) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS unidades (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  magnitud_id INT UNSIGNED NOT NULL,
  nombre VARCHAR(80) NOT NULL,
  simbolo VARCHAR(20) NOT NULL,
  factor_base DECIMAL(18,8) NOT NULL DEFAULT 1,
  UNIQUE KEY uq_unidad_magnitud_simbolo (magnitud_id, simbolo),
  CONSTRAINT fk_unidades_magnitud
    FOREIGN KEY (magnitud_id) REFERENCES magnitudes(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS bancos_valores_seccion (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  seccion_tp_id INT UNSIGNED NOT NULL,
  magnitud_id INT UNSIGNED NOT NULL,
  unidad_id INT UNSIGNED NOT NULL,
  nombre VARCHAR(80) NOT NULL,
  codigo VARCHAR(40) NOT NULL,
  descripcion VARCHAR(180) NULL,
  orden INT UNSIGNED NOT NULL DEFAULT 100,
  activo TINYINT(1) NOT NULL DEFAULT 1,
  UNIQUE KEY uq_banco_seccion_codigo (seccion_tp_id, codigo),
  CONSTRAINT fk_bancos_seccion
    FOREIGN KEY (seccion_tp_id) REFERENCES secciones_tp(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_bancos_magnitud
    FOREIGN KEY (magnitud_id) REFERENCES magnitudes(id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_bancos_unidad
    FOREIGN KEY (unidad_id) REFERENCES unidades(id)
    ON DELETE RESTRICT,
  INDEX idx_bancos_seccion (seccion_tp_id, activo, orden)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS valores_banco_seccion (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  banco_valores_seccion_id INT UNSIGNED NOT NULL,
  indice INT UNSIGNED NOT NULL,
  valor DECIMAL(14,4) NOT NULL,
  etiqueta VARCHAR(60) NULL,
  activo TINYINT(1) NOT NULL DEFAULT 1,
  UNIQUE KEY uq_valor_banco_indice (banco_valores_seccion_id, indice),
  UNIQUE KEY uq_valor_banco_valor (banco_valores_seccion_id, valor),
  CONSTRAINT fk_valores_banco
    FOREIGN KEY (banco_valores_seccion_id) REFERENCES bancos_valores_seccion(id)
    ON DELETE CASCADE,
  INDEX idx_valores_banco_activo (banco_valores_seccion_id, activo, indice)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ejercicios (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  actividad_id INT UNSIGNED NOT NULL,
  seccion_tp_id INT UNSIGNED NULL,
  codigo VARCHAR(80) NULL UNIQUE,
  consigna TEXT NOT NULL,
  explicacion TEXT NOT NULL,
  formula_respuesta VARCHAR(255) NULL,
  tolerancia DECIMAL(14,6) NULL,
  orden INT UNSIGNED NOT NULL DEFAULT 100,
  activo TINYINT(1) NOT NULL DEFAULT 1,
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_ejercicios_actividad
    FOREIGN KEY (actividad_id) REFERENCES actividades(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_ejercicios_seccion_tp
    FOREIGN KEY (seccion_tp_id) REFERENCES secciones_tp(id)
    ON DELETE SET NULL,
  INDEX idx_ejercicios_actividad (actividad_id),
  INDEX idx_ejercicios_seccion_tp (seccion_tp_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS variables_ejercicio (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  ejercicio_id INT UNSIGNED NOT NULL,
  magnitud_id INT UNSIGNED NOT NULL,
  unidad_id INT UNSIGNED NOT NULL,
  banco_valores_seccion_id INT UNSIGNED NULL,
  nombre VARCHAR(40) NOT NULL,
  etiqueta VARCHAR(60) NOT NULL,
  descripcion VARCHAR(180) NULL,
  orden INT UNSIGNED NOT NULL DEFAULT 100,
  UNIQUE KEY uq_variable_ejercicio_nombre (ejercicio_id, nombre),
  CONSTRAINT fk_variables_ejercicio
    FOREIGN KEY (ejercicio_id) REFERENCES ejercicios(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_variables_magnitud
    FOREIGN KEY (magnitud_id) REFERENCES magnitudes(id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_variables_unidad
    FOREIGN KEY (unidad_id) REFERENCES unidades(id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_variables_banco_seccion
    FOREIGN KEY (banco_valores_seccion_id) REFERENCES bancos_valores_seccion(id)
    ON DELETE SET NULL,
  INDEX idx_variables_ejercicio (ejercicio_id),
  INDEX idx_variables_banco_seccion (banco_valores_seccion_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS valores_variable (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  variable_ejercicio_id INT UNSIGNED NOT NULL,
  valor DECIMAL(14,4) NOT NULL,
  activo TINYINT(1) NOT NULL DEFAULT 1,
  orden INT UNSIGNED NOT NULL DEFAULT 100,
  UNIQUE KEY uq_valor_variable (variable_ejercicio_id, valor),
  CONSTRAINT fk_valores_variable
    FOREIGN KEY (variable_ejercicio_id) REFERENCES variables_ejercicio(id)
    ON DELETE CASCADE,
  INDEX idx_valores_variable (variable_ejercicio_id, activo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS combinaciones_ejercicio (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  ejercicio_id INT UNSIGNED NOT NULL,
  codigo_hash CHAR(64) NOT NULL,
  codigo_combinacion VARCHAR(80) NULL,
  respuesta_numero DECIMAL(18,6) NULL,
  respuesta_texto VARCHAR(160) NULL,
  usos INT UNSIGNED NOT NULL DEFAULT 0,
  ciclo INT UNSIGNED NOT NULL DEFAULT 1,
  activa TINYINT(1) NOT NULL DEFAULT 1,
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_combinacion_ejercicio_hash (ejercicio_id, codigo_hash),
  CONSTRAINT fk_combinaciones_ejercicio
    FOREIGN KEY (ejercicio_id) REFERENCES ejercicios(id)
    ON DELETE CASCADE,
  INDEX idx_combinaciones_disponibles (ejercicio_id, activa, usos),
  INDEX idx_combinaciones_codigo (ejercicio_id, codigo_combinacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS combinacion_valores (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  combinacion_ejercicio_id INT UNSIGNED NOT NULL,
  variable_ejercicio_id INT UNSIGNED NOT NULL,
  valor_variable_id INT UNSIGNED NOT NULL,
  valor DECIMAL(14,4) NOT NULL,
  UNIQUE KEY uq_combinacion_variable (combinacion_ejercicio_id, variable_ejercicio_id),
  CONSTRAINT fk_combinacion_valores_combinacion
    FOREIGN KEY (combinacion_ejercicio_id) REFERENCES combinaciones_ejercicio(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_combinacion_valores_variable
    FOREIGN KEY (variable_ejercicio_id) REFERENCES variables_ejercicio(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_combinacion_valores_valor
    FOREIGN KEY (valor_variable_id) REFERENCES valores_variable(id)
    ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS opciones_ejercicio (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  ejercicio_id INT UNSIGNED NOT NULL,
  texto VARCHAR(160) NOT NULL,
  es_correcta TINYINT(1) NOT NULL DEFAULT 0,
  orden INT UNSIGNED NOT NULL DEFAULT 100,
  CONSTRAINT fk_opciones_ejercicio
    FOREIGN KEY (ejercicio_id) REFERENCES ejercicios(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS valores_actividad (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  actividad_id INT UNSIGNED NOT NULL,
  magnitud_id INT UNSIGNED NOT NULL,
  unidad_id INT UNSIGNED NOT NULL,
  etiqueta VARCHAR(60) NOT NULL,
  valor DECIMAL(14,4) NOT NULL,
  descripcion VARCHAR(180) NULL,
  orden INT UNSIGNED NOT NULL DEFAULT 100,
  CONSTRAINT fk_valores_actividad
    FOREIGN KEY (actividad_id) REFERENCES actividades(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_valores_magnitud
    FOREIGN KEY (magnitud_id) REFERENCES magnitudes(id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_valores_unidad
    FOREIGN KEY (unidad_id) REFERENCES unidades(id)
    ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS intentos (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  alumno_id INT UNSIGNED NOT NULL,
  actividad_id INT UNSIGNED NOT NULL,
  modo VARCHAR(20) NOT NULL DEFAULT 'evaluativo',
  estado VARCHAR(20) NOT NULL DEFAULT 'iniciado',
  ultimo_ejercicio_id INT UNSIGNED NULL,
  correctas INT UNSIGNED NOT NULL DEFAULT 0,
  cantidad_respuestas INT UNSIGNED NOT NULL DEFAULT 0,
  puntaje INT UNSIGNED NOT NULL DEFAULT 0,
  iniciado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ultimo_acceso_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  finalizado_en DATETIME NULL,
  duracion_segundos INT UNSIGNED NOT NULL DEFAULT 0,
  CONSTRAINT fk_intentos_alumno
    FOREIGN KEY (alumno_id) REFERENCES alumnos(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_intentos_actividad
    FOREIGN KEY (actividad_id) REFERENCES actividades(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_intentos_ultimo_ejercicio
    FOREIGN KEY (ultimo_ejercicio_id) REFERENCES ejercicios(id)
    ON DELETE SET NULL,
  INDEX idx_intentos_alumno_actividad (alumno_id, actividad_id),
  INDEX idx_intentos_estado (estado, modo),
  INDEX idx_intentos_ultimo_acceso (ultimo_acceso_en)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS respuestas (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  intento_id INT UNSIGNED NOT NULL,
  ejercicio_id INT UNSIGNED NOT NULL,
  combinacion_ejercicio_id INT UNSIGNED NULL,
  opcion_ejercicio_id INT UNSIGNED NULL,
  respuesta_texto VARCHAR(255) NULL,
  respuesta_numero DECIMAL(18,6) NULL,
  correcta TINYINT(1) NOT NULL DEFAULT 0,
  estado_revision VARCHAR(20) NOT NULL DEFAULT 'pendiente',
  puntos_docente DECIMAL(6,2) NULL,
  comentario_docente TEXT NULL,
  revisado_en DATETIME NULL,
  respondido_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_respuesta_intento_ejercicio (intento_id, ejercicio_id),
  CONSTRAINT fk_respuestas_intento
    FOREIGN KEY (intento_id) REFERENCES intentos(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_respuestas_ejercicio
    FOREIGN KEY (ejercicio_id) REFERENCES ejercicios(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_respuestas_opcion
    FOREIGN KEY (opcion_ejercicio_id) REFERENCES opciones_ejercicio(id)
    ON DELETE SET NULL,
  CONSTRAINT fk_respuestas_combinacion
    FOREIGN KEY (combinacion_ejercicio_id) REFERENCES combinaciones_ejercicio(id)
    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS asignaciones_combinacion (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  alumno_id INT UNSIGNED NOT NULL,
  ejercicio_id INT UNSIGNED NOT NULL,
  combinacion_ejercicio_id INT UNSIGNED NOT NULL,
  intento_id INT UNSIGNED NULL,
  asignado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_asignacion_alumno_ejercicio (alumno_id, ejercicio_id),
  CONSTRAINT fk_asignaciones_alumno
    FOREIGN KEY (alumno_id) REFERENCES alumnos(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_asignaciones_ejercicio
    FOREIGN KEY (ejercicio_id) REFERENCES ejercicios(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_asignaciones_combinacion
    FOREIGN KEY (combinacion_ejercicio_id) REFERENCES combinaciones_ejercicio(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_asignaciones_intento
    FOREIGN KEY (intento_id) REFERENCES intentos(id)
    ON DELETE SET NULL,
  INDEX idx_asignaciones_ejercicio_combinacion (ejercicio_id, combinacion_ejercicio_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS movimientos_puntos (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  alumno_id INT UNSIGNED NOT NULL,
  actividad_id INT UNSIGNED NULL,
  intento_id INT UNSIGNED NULL,
  puntos INT NOT NULL,
  motivo VARCHAR(160) NOT NULL,
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_movimientos_alumno
    FOREIGN KEY (alumno_id) REFERENCES alumnos(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_movimientos_actividad
    FOREIGN KEY (actividad_id) REFERENCES actividades(id)
    ON DELETE SET NULL,
  CONSTRAINT fk_movimientos_intento
    FOREIGN KEY (intento_id) REFERENCES intentos(id)
    ON DELETE SET NULL,
  INDEX idx_movimientos_alumno_fecha (alumno_id, creado_en),
  INDEX idx_movimientos_actividad (actividad_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE OR REPLACE VIEW vista_actividades_publicadas AS
SELECT
  a.id,
  t.nombre AS tema,
  tp.titulo AS trabajo_practico,
  st.titulo AS seccion,
  a.titulo AS actividad,
  a.estado,
  a.visible_alumno,
  a.acceso_habilitado,
  a.puntaje_habilitado,
  COUNT(e.id) AS ejercicios
FROM actividades a
INNER JOIN contenedores_actividad ca ON ca.id = a.contenedor_id
INNER JOIN temas t ON t.id = ca.tema_id
LEFT JOIN secciones_tp st ON st.id = a.seccion_tp_id
LEFT JOIN trabajos_practicos tp ON tp.id = st.trabajo_practico_id
LEFT JOIN ejercicios e ON e.actividad_id = a.id AND e.activo = 1
GROUP BY a.id, t.nombre, tp.titulo, st.titulo;

CREATE OR REPLACE VIEW vista_progreso_alumnos AS
SELECT
  al.id AS alumno_id,
  al.dni,
  al.nombre AS alumno,
  c.nombre AS curso,
  a.id AS actividad_id,
  a.titulo AS actividad,
  i.id AS intento_id,
  i.modo,
  i.estado,
  i.correctas,
  i.cantidad_respuestas,
  i.puntaje,
  i.iniciado_en,
  i.ultimo_acceso_en,
  i.finalizado_en,
  i.duracion_segundos
FROM intentos i
INNER JOIN alumnos al ON al.id = i.alumno_id
INNER JOIN actividades a ON a.id = i.actividad_id
LEFT JOIN inscripciones ins ON ins.alumno_id = al.id AND ins.activo = 1
LEFT JOIN cursos c ON c.id = ins.curso_id;
