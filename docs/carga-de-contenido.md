# Carga de contenido

El backend ya permite cargar contenido sin modificar la estructura de la base.

## Orden recomendado

1. Crear o elegir un tema.
2. Crear el trabajo practico.
3. Crear las secciones del TP.
4. Crear una actividad publicada para cada seccion que se quiera mostrar.
5. Cargar ejercicios, variables y combinaciones.

## Endpoints admin

Todos responden JSON con `ok` y `data`.

### Cursos

`GET /api/admin/cursos.php`

`POST /api/admin/cursos.php`

```json
{
  "nombre": "Electrotecnia 1",
  "especialidad": "Electrotecnia",
  "turno": "Manana",
  "ciclo_lectivo": 2026,
  "activo": true
}
```

### Alumnos

`GET /api/admin/alumnos.php`

`GET /api/admin/alumnos.php?curso_id=101`

`POST /api/admin/alumnos.php`

```json
{
  "dni": "90000003",
  "nombre": "Alumno de ejemplo 03",
  "fecha_nacimiento": "2011-05-20",
  "curso_id": 101
}
```

### Temas

`GET /api/admin/temas.php`

Lista temas.

`POST /api/admin/temas.php`

```json
{
  "nombre": "Ley de Ohm",
  "descripcion": "Relacion entre tension, corriente y resistencia.",
  "orden": 20,
  "activo": true
}
```

`PUT /api/admin/temas.php?id=1`

Actualiza un tema.

### Trabajos practicos

`GET /api/admin/trabajos-practicos.php`

`GET /api/admin/trabajos-practicos.php?tema_id=2`

`POST /api/admin/trabajos-practicos.php`

```json
{
  "tema_id": 2,
  "titulo": "TP 02 - Ley de Ohm",
  "descripcion": "TP dividido en tres secciones.",
  "codigo": "tp-ley-ohm-02",
  "activo": true
}
```

### Secciones

`GET /api/admin/secciones.php`

`GET /api/admin/secciones.php?trabajo_practico_id=2`

`POST /api/admin/secciones.php`

```json
{
  "trabajo_practico_id": 2,
  "titulo": "Seccion 1 - Despeje de resistencia",
  "descripcion": "Calculo de R con V e I.",
  "orden": 10,
  "activo": true
}
```

### Contenedores

`GET /api/admin/contenedores.php`

`GET /api/admin/contenedores.php?tema_id=2`

Sirve para elegir el `contenedor_id` al crear actividades.

### Actividades

`GET /api/admin/actividades.php`

`POST /api/admin/actividades.php`

```json
{
  "contenedor_id": 3,
  "seccion_tp_id": 4,
  "titulo": "Ley de Ohm - Seccion 1",
  "descripcion": "Practica de calculo de resistencia.",
  "nivel": "Inicial",
  "puntos": 10,
  "estado": "Disponible",
  "visible_alumno": true,
  "acceso_habilitado": true,
  "puntaje_habilitado": false,
  "icono": "R",
  "orden": 10
}
```

`PUT /api/admin/actividades.php?id=1`

Actualiza una actividad.

### Habilitar actividad

`PATCH /api/admin/habilitar-actividad.php?id=1`

```json
{
  "visible_alumno": true,
  "acceso_habilitado": true,
  "puntaje_habilitado": true,
  "estado": "Disponible"
}
```

## Regla de cuidado

No conviene borrar fisicamente temas, TPs, secciones o actividades si ya hubo alumnos trabajando. Primero se usa `activo = false`, `visible_alumno = false` o `acceso_habilitado = false`.

## Carga preparada

Para el primer curso y el TP5 de Ley de Ohm quedo preparado:

```powershell
C:\xampp\mysql\bin\mysql.exe -u root electrodesafio < database\carga-tp5-ley-ohm.sql
```

Ese archivo carga:

- curso `Electrotecnia 1`
- 18 alumnos
- inscripciones al curso
- TP5 de Ley de Ohm
- 3 secciones
- 3 actividades visibles en modo practica
- 16 ejercicios resumidos del TP
