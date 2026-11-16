# Base de datos

Esta etapa usa una base separada para evitar cruces con la etapa actual.

Nombre sugerido:

```text
materias_mica
```

Archivo inicial:

```text
database/estructura.sql
```

Tablas iniciales:

- `materias`: Lengua, Historia y Ciencias Naturales.
- `actividades`: trabajos o unidades por materia.
- `consignas`: preguntas o consignas de cada actividad.

Cuando el modelo este mas definido se pueden agregar alumnos, cursos, respuestas e intentos, o reutilizar los de la etapa principal.
