SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

UPDATE actividades
SET visible_alumno = 0,
    acceso_habilitado = 0,
    puntaje_habilitado = 0,
    estado = 'Oculta'
WHERE titulo IN ('Circuitos en serie', 'Ley de Ohm', 'Mediciones reales');
