# --- Etapa 1: Instalar dependencias con Composer ---
# Usamos una imagen oficial de Composer para mantener la imagen final limpia.
FROM composer:2.7 as vendor

WORKDIR /app
# Copiamos solo los archivos necesarios para instalar dependencias.
COPY database/ database/
COPY composer.json composer.json
COPY composer.lock composer.lock

# Instalamos dependencias optimizadas para producción, ignorando los scripts de post-instalación por ahora.
RUN composer install --no-interaction --no-plugins --no-dev --no-scripts --prefer-dist --optimize-autoloader


# --- Etapa 2: Construir la imagen final de la aplicación ---
# Usamos una imagen oficial de PHP 8.2.
FROM php:8.2-fpm

# Instalar dependencias del sistema y extensiones de PHP necesarias para Laravel.
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Establecer el directorio de trabajo.
WORKDIR /var/www

# Copiar el código de la aplicación.
COPY . .

# Copiar las dependencias instaladas en la etapa anterior.
COPY --from=vendor /app/vendor/ /var/www/vendor/

# Asignar permisos correctos para que Laravel pueda escribir en logs y cache.
# Esto es fundamental para evitar errores en producción.
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Copiar el script de inicio y hacerlo ejecutable.
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Exponer el puerto 8000, que es el que usará "php artisan serve".
EXPOSE 8000

# Definir el punto de entrada que ejecutará nuestro script.
ENTRYPOINT ["docker-entrypoint.sh"]

# Comando por defecto que se pasará al script de entrada.
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
