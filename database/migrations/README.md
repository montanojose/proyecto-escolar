# Migraciones

Usar esta carpeta para cambios incrementales de base de datos.

## Nombre

Formato recomendado:

```text
YYYY-MM-DD-descripcion-corta.sql
```

Ejemplos:

```text
2026-08-13-lengua-sujeto-predicado.sql
2026-08-14-matematica-funcion-racional.sql
```

## Reglas

- No guardar dumps completos aca.
- Preferir scripts que puedan ejecutarse una sola vez sin romper datos existentes.
- Usar `CREATE TABLE IF NOT EXISTS` para tablas nuevas.
- Usar `INSERT ... WHERE NOT EXISTS` u `ON DUPLICATE KEY UPDATE` para datos base.
- No borrar respuestas, intentos ni alumnos reales en una migracion de actividad.
- Si una migracion requiere una accion manual, aclararla con comentarios al inicio del SQL.

## Despliegue

Cuando se sube una version al hosting, importar solo las migraciones que todavia no se aplicaron en phpMyAdmin.
