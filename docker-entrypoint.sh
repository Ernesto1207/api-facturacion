#!/bin/bash

# Activa la salida inmediata si un comando falla.
set -e

# Esperamos un momento para asegurar que la base de datos esté lista si se inicia al mismo tiempo.
# En un entorno real, se podrían usar herramientas más avanzadas como wait-for-it.sh,
# pero un sleep simple suele ser suficiente.
echo "Esperando a la base de datos..."
sleep 5

# Ejecuta las migraciones de la base de datos.
# El flag --force es importante para que se ejecute sin preguntar en entornos automatizados.
echo "Ejecutando migraciones..."
php artisan migrate --force

# Finalmente, ejecuta el comando principal que se pasó al contenedor (el CMD del Dockerfile).
# Esto iniciará "php artisan serve".
exec "$@"