# Instalación en hosting

1. Subir el contenido de `public_html` a la carpeta pública del hosting.
2. Subir `app_private` fuera de la carpeta pública cuando el hosting lo permita. Si no se puede, proteger esa carpeta desde el panel o con reglas del servidor.
3. Crear una base MySQL y ejecutar:

```sql
SOURCE database/estructura.sql;
SOURCE database/datos-iniciales.sql;
```

4. Configurar las credenciales reales con variables de entorno si el hosting las permite:

- `DB_HOST`
- `DB_PORT`
- `DB_NAME`
- `DB_USER`
- `DB_PASS`

Si el hosting no permite variables de entorno, cambiar temporalmente los valores por defecto en `app_private/config/database.php`.

5. Probar:

- `/index.php`
- `/api/obtener-ejercicio.php`
- `/api/validar-dni.php`
