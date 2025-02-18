FROM drupal:10.2.0-php8.2-fpm

# Actualizar paquetes y caché de apt e instalar dependencias necesarias en un solo RUN
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    libicu-dev \
    libonig-dev \
    libzip-dev \
    libpq-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    mariadb-client \
    libxml2-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd iconv mbstring pdo_mysql zip intl dom

# Limpiar caché de apt para reducir el tamaño de la imagen
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalar Composer globalmente
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Instala Drush globalmente con Composer
RUN composer global require drush/drush

# Establecer permisos
RUN chown -R www-data:www-data /var/www/html

# Definir directorio de trabajo
WORKDIR /var/www/html

# Instalar dependencias si existe composer.json
RUN if [ -f "composer.json" ]; then composer install --no-interaction --optimize-autoloader; fi
