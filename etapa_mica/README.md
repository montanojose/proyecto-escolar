# Etapa Mica

Espacio independiente para trabajar las materias Lengua, Historia y Ciencias Naturales sin tocar la etapa actual de Electrotecnia.

## Estructura

```text
etapa_mica/
  public_html/          Archivos publicos para el subdominio o carpeta web
  public_html/api/      Endpoints PHP propios de esta etapa
  public_html/assets/   CSS, JS e imagenes propias
  app_private/          Configuracion y servicios privados
  database/             Estructura y datos SQL de esta etapa
  docs/                 Notas de trabajo
  src/                  Reservado si despues se usa React/Vite
```

## Reglas para no chocar

- No editar `public_html/`, `app_private/`, `database/` ni `src/` de la raiz si el cambio es solo para esta etapa.
- Todo lo nuevo de Lengua, Historia y Ciencias Naturales debe quedar dentro de `etapa_mica/`.
- Usar una base de datos separada, por ejemplo `materias_mica`.
- Si mas adelante se decide unificar, se migra desde esta carpeta hacia la estructura principal.

## Primer uso local

1. Crear la base de datos `materias_mica` en MySQL.
2. Importar `database/estructura.sql`.
3. Abrir `etapa_mica/public_html/index.php` desde el subdominio o desde XAMPP.
4. Para probar la API, abrir `etapa_mica/public_html/api/estado.php`.

## Variables opcionales

La conexion lee estas variables si existen:

```text
MICA_DB_HOST
MICA_DB_PORT
MICA_DB_NAME
MICA_DB_USER
MICA_DB_PASS
```

Si no existen, usa valores locales de XAMPP.
