# --- Etapa 1: Instalar dependencias con Composer en un entorno completo ---
# Cambiamos la base a una imagen de PHP para poder instalar extensiones.
FROM php:8.2-fpm AS vendor

# Instalar dependencias del sistema necesarias para las extensiones de PHP y Composer.
RUN apt-get update && apt-get install -y \
    unzip \
    libxml2-dev \
    libpng-dev \
    libonig-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalar las extensiones de PHP que tu proyecto requiere (bcmath y soap).
RUN docker-php-ext-install bcmath soap

# Instalar Composer.
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app

# Copiar solo los archivos necesarios para instalar dependencias.
COPY database/ database/
COPY composer.json composer.json
COPY composer.lock composer.lock

# Ahora, este comando se ejecutará en un entorno que SÍ tiene las extensiones requeridas.
RUN composer install --no-interaction --no-plugins --no-dev --no-scripts --prefer-dist --optimize-autoloader


# --- Etapa 2: Construir la imagen final de la aplicación ---
# Usamos la misma versión de PHP para consistencia.
FROM php:8.2-fpm

# Instalar dependencias del sistema y TODAS las extensiones que la app necesita para EJECUTARSE.
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd soap

# Establecer el directorio de trabajo.
WORKDIR /var/www

# Copiar el código de la aplicación.
COPY . .

# Copiar las dependencias instaladas en la etapa anterior.
COPY --from=vendor /app/vendor/ /var/www/vendor/

# Asignar permisos correctos.
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Copiar el script de inicio y hacerlo ejecutable.
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Exponer el puerto 8000.
EXPOSE 8000

# Definir el punto de entrada.
ENTRYPOINT ["docker-entrypoint.sh"]

# Comando por defecto.
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]