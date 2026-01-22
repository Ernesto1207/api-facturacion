#!/bin/bash

# Detener el script si hay errores
set -e

echo "--- Iniciando configuración de entorno ---"

# 1. Copiar .env.example a .env si no existe
if [ ! -f .env ]; then
    echo "El archivo .env no existe. Copiando desde .env.example..."
    cp .env.example .env
else
    echo "El archivo .env ya existe."
fi

# 2. Instalar dependencias si la carpeta vendor no existe (por seguridad)
if [ ! -d "vendor" ]; then
    echo "Instalando dependencias de Composer..."
    composer install --no-interaction --no-plugins --no-scripts --prefer-dist
fi

# 3. Generar la APP_KEY si no está configurada
if grep -q "APP_KEY=" .env && [ -z "$(grep "APP_KEY=" .env | cut -d '=' -f 2)" ]; then
    echo "Generando Application Key..."
    php artisan key:generate
elif ! grep -q "APP_KEY=" .env; then
     # Si la linea ni siquiera existe
    echo "Generando Application Key..."
    php artisan key:generate
else
    echo "La Application Key ya está configurada."
fi

# 4. Esperar a la base de datos
echo "Esperando a que la base de datos esté lista..."
# Un sleep simple suele funcionar, pero lo ideal es un loop de espera
sleep 10 

# 5. Ejecutar migraciones
echo "Ejecutando migraciones..."
php artisan migrate --force

echo "--- Configuración terminada. Iniciando servidor ---"

# 6. Ejecutar el comando pasado al contenedor (php artisan serve)
exec "$@"