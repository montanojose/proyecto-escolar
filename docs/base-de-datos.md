# Base de datos

El diseño apunta a tercera forma normal: cada tabla guarda un solo tipo de dato, los datos repetibles se separan en tablas propias y las relaciones se hacen con claves foráneas.

## Instalación local

1. Encender Apache y MySQL desde XAMPP.
2. Importar el esquema:

```powershell
C:\xampp\mysql\bin\mysql.exe -u root < database\estructura.sql
```

3. Cargar datos iniciales:

```powershell
C:\xampp\mysql\bin\mysql.exe -u root < database\datos-iniciales.sql
```

4. Opcionalmente cargar movimientos de prueba:

```powershell
C:\xampp\mysql\bin\mysql.exe -u root electrodesafio < database\ejemplos.sql
```

## Bloque académico

`alumnos`
: Datos propios del alumno: DNI, nombre y fecha de nacimiento. No guarda curso directamente porque un alumno puede cambiar de curso o cursar en otro ciclo lectivo.

`cursos`
: Curso, especialidad, turno y ciclo lectivo. Esto permite crecer a más cursos o más años sin cambiar la estructura.

`inscripciones`
: Une alumnos con cursos. Es la tabla puente que dice “este alumno pertenece a este curso en este ciclo”.

`tipos_calificacion`
: Catálogo de tipos de nota: trabajo práctico, evaluación escrita, lección oral, integrador, desafío, etc.

`calificaciones`
: Cada nota concreta. Pertenece a una inscripción y a un tipo de calificación.

## Bloque de actividades

`temas`
: Grandes temas de la materia, por ejemplo Circuitos básicos, Ley de Ohm o Mediciones eléctricas.

`trabajos_practicos`
: Un TP completo asociado a un tema. Por ejemplo, “TP 02 - Ley de Ohm”. Esta tabla permite cargar trabajos grandes sin cambiar la estructura de la base.

`secciones_tp`
: Partes del TP. Si un TP tiene 15 ejercicios y lo dividimos en 3 bloques, se cargan 3 secciones y los ejercicios se asocian a cada una.

`contenedores_actividad`
: Los “cajones”, accesos o bloques dentro de un tema. Sirven para organizar varias actividades por tema sin endurecer el diseño.

`actividades`
: Actividades que ve el alumno. Pueden publicar una sección de TP o una actividad independiente. Tienen nivel, puntos máximos, estado e icono. También incluyen tres controles docentes:

- `visible_alumno`: si vale `1`, aparece en la pantalla del alumno.
- `acceso_habilitado`: si vale `1`, el alumno puede entrar.
- `puntaje_habilitado`: si vale `1`, el intento suma puntos al finalizar.

Con esto se cubren tres casos:

- Visible y con puntaje: actividad oficial evaluativa.
- Visible sin puntaje: actividad de práctica; se guarda progreso y tiempo, pero no suma puntos.
- Visible sin acceso: el alumno la ve, pero todavía no puede entrar.

`ejercicios`
: Preguntas o desafíos dentro de una actividad. La consigna puede tener variables entre llaves, por ejemplo `{{R1}}`, `{{R2}}`, `{{V}}` o `{{I}}`. También puede guardar una formula de respuesta y una tolerancia.

`opciones_ejercicio`
: Opciones posibles de cada ejercicio. La correcta se marca con `es_correcta`.

## Bloque eléctrico adaptable

`magnitudes`
: Tipos de magnitud: resistencia, tensión, corriente, capacitancia, inductancia, ángulo.

`unidades`
: Unidades asociadas a una magnitud: Ω, V, A, µF, mH, grados, etc.

`valores_actividad`
: Banco de valores que puede usar una actividad. Por ejemplo R1 = 6 Ω, Vfuente = 12 V o C1 = 10 µF. Esto evita inventar valores sueltos en el código y deja preparada la plataforma para distintos trabajos.

`variables_ejercicio`
: Define que variables usa una estructura de ejercicio. Por ejemplo, el ejercicio de resistencia equivalente puede usar `R1` y `R2`, ambas de magnitud resistencia y unidad ohm.

`valores_variable`
: Banco de valores posibles para cada variable. Por ejemplo, para `R1`: 4, 6, 8; para `R2`: 4, 6, 8.

`combinaciones_ejercicio`
: Combinaciones ya armadas para un ejercicio. Guarda un hash unico, la respuesta numerica esperada, la respuesta textual y cuantos usos tuvo.

`combinacion_valores`
: Detalle de valores de cada combinacion. Por ejemplo, combinacion 1: R1 = 4 y R2 = 6.

`asignaciones_combinacion`
: Registra que combinacion le toco a cada alumno en cada ejercicio. Esto evita que el mismo alumno reciba otra combinacion si retoma el intento.

## Como se logran ejercicios distintos por alumno

La estructura del ejercicio es la misma para todos:

```txt
Cual es la resistencia equivalente con R1 = {{R1}} y R2 = {{R2}}?
```

Pero cada alumno recibe una combinacion distinta:

```txt
Alumno A: R1 = 4, R2 = 6, respuesta = 10
Alumno B: R1 = 6, R2 = 6, respuesta = 12
Alumno C: R1 = 8, R2 = 4, respuesta = 12
```

Cuando se asigna una combinacion, queda guardada. El sistema puede elegir primero las combinaciones menos usadas. Si todas ya fueron usadas, se permite reutilizar la de menor cantidad de usos.

Este modelo tambien permite controlar respuestas no absolutas. Por ejemplo, una respuesta numerica puede aceptarse con tolerancia:

```txt
respuesta esperada = 2.00 A
tolerancia = 0.01
acepta desde 1.99 hasta 2.01
```

Para respuestas conceptuales o multiples choice se puede seguir usando `opciones_ejercicio`.

## Cargar TPs sin modificar la base

Cuando llega un TP nuevo no se crean tablas nuevas. Se cargan registros:

1. Crear o reutilizar un `tema`.
2. Crear un `trabajo_practico`.
3. Crear sus `secciones_tp`.
4. Crear una `actividad` por sección que se quiera publicar.
5. Cargar `ejercicios`.
6. Cargar `variables_ejercicio` y `valores_variable`.
7. Generar `combinaciones_ejercicio` y `combinacion_valores`.

Esto evita migraciones destructivas y reduce el riesgo de perder datos.

## Vistas y procedimientos

`vista_actividades_publicadas`
: Resume tema, TP, sección, actividad, estado y cantidad de ejercicios.

`vista_progreso_alumnos`
: Resume alumno, curso, actividad, intento, progreso, puntaje y tiempos.

`sp_asignar_combinacion`
: Recibe alumno, ejercicio e intento. Si el alumno ya tenía combinación asignada, devuelve la misma. Si no tenía, elige una combinación activa con menor cantidad de usos, la asigna y aumenta su contador.

La lógica PHP debe llamar procedimientos y operaciones críticas dentro de transacciones PDO con `try/catch`, especialmente al iniciar intentos, asignar combinaciones, guardar respuestas y finalizar actividades.

## Bloque de juego y puntajes

`intentos`
: Un intento de un alumno en una actividad. Guarda modo, estado, último ejercicio resuelto, correctas, cantidad de respuestas, puntaje, inicio, último acceso, finalización y duración.

El campo `modo` puede ser:

- `evaluativo`: puede generar movimiento de puntos.
- `practica`: registra trabajo del alumno, pero no genera puntos.

`respuestas`
: Respuestas por ejercicio dentro de un intento.

`movimientos_puntos`
: Historial de puntos ganados o ajustados. Registra alumno, actividad, intento, puntos y motivo.

Solo se crea un movimiento cuando la actividad tenía `puntaje_habilitado = 1` al finalizar el intento.

## Configuración

El backend usa MySQL/MariaDB con PDO. La configuración por defecto está pensada para XAMPP:

- Host: `127.0.0.1`
- Puerto: `3306`
- Base: `electrodesafio`
- Usuario: `root`
- Password: vacío

También se puede cambiar con variables de entorno: `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASS`.
