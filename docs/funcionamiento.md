# Funcionamiento

La pantalla principal esta en la app React:

- Entrada: `src/main.tsx`
- Router: `src/app/App.tsx`
- Vista actual: `src/app/LegacyApp.tsx`

El build se publica en `public_html/assets/app` y `public_html/index.php` carga esos archivos.

## Endpoints alumno

Los endpoints JSON viven en `public_html/api`:

- `validar-dni.php`: recibe `{ "dni": "90000001" }` y devuelve el alumno si ya fue cargado por el docente.
- `obtener-ejercicio.php`: sin parametros devuelve actividades; con `?actividad_id=1` devuelve ejercicios.
- `validar-respuesta.php`: recibe ejercicio y respuesta, devuelve si es correcta.
- `iniciar-intento.php`: crea un intento pendiente.
- `guardar-progreso.php`: guarda una respuesta dentro de un intento.
- `finalizar-actividad.php`: guarda resultado final y movimiento de puntos si corresponde.
- `historial-alumno.php`: devuelve intentos, progreso, tiempo y puntos de un alumno.

## Endpoints docente

Los endpoints de carga y seguimiento docente viven en `public_html/api/admin`:

- `cursos.php`
- `alumnos.php`
- `temas.php`
- `trabajos-practicos.php`
- `secciones.php`
- `contenedores.php`
- `actividades.php`
- `habilitar-actividad.php`
- `progreso.php`: lista intentos por curso y, con `intento_id`, devuelve respuestas guardadas.
- `corregir-respuesta.php`: permite marcar una respuesta como `correcta` o `incorrecta`, con comentario y puntos manuales.
- `resumen-alumno.php`: devuelve intentos, respuestas, pendientes, correctas, puntos manuales y tiempo total.
- `exportar-progreso.php`: exporta progreso filtrado en CSV.

Todos los JSON responden con:

```json
{
  "ok": true,
  "data": {}
}
```

En errores:

```json
{
  "ok": false,
  "message": "Mensaje legible"
}
```

## Reglas de habilitacion

El profesor controla cada actividad con tres campos:

- `visible_alumno`: aparece o no aparece en la lista.
- `acceso_habilitado`: permite o bloquea el ingreso.
- `puntaje_habilitado`: define si el intento suma puntos.

En el panel docente se manejan cuatro modos:

- Oculta: no aparece al alumno.
- Bloqueada: aparece, pero no deja entrar.
- Practica: deja entrar, guarda progreso, no suma puntos.
- Con puntos: deja entrar, guarda progreso y puede sumar puntos al finalizar.

## Correccion numerica

`validar-respuesta.php` interpreta respuestas numericas con unidades comunes:

- Corriente: `A`, `mA`, `uA`, `kA`
- Tension: `V`, `mV`, `kV`
- Resistencia: `ohm`, `k`, `kohm`, `M`, `Mohm`

Si el ejercicio tiene una combinacion con `respuesta_numero`, compara contra ese valor usando la tolerancia del ejercicio.

Si el ejercicio no tiene combinacion numerica ni opcion correcta, queda como respuesta abierta para revision docente.

## Hosting compartido

El sistema esta organizado para funcionar en hosting compartido:

- `public_html/index.php` carga la app compilada.
- Los endpoints viven como archivos PHP simples bajo `public_html/api`.
- La configuracion PDO esta en `app_private/config/database.php`.
- No requiere procesos en segundo plano ni servidor Node en produccion.
- Para publicar cambios de frontend, correr `npm.cmd run build` y subir `public_html/assets/app`.
