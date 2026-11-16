USE electrodesafio;

START TRANSACTION;

UPDATE combinaciones_ejercicio ce
INNER JOIN ejercicios e ON e.id = ce.ejercicio_id
SET ce.activa = 0
WHERE e.codigo LIKE 'tp5-%';

UPDATE variables_ejercicio ve
INNER JOIN ejercicios e ON e.id = ve.ejercicio_id
SET ve.banco_valores_seccion_id = NULL
WHERE e.codigo LIKE 'tp5-%';

COMMIT;
