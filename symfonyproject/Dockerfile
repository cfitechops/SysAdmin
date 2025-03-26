# Utilise l'image officielle PHP 8.2 avec Apache
FROM php:8.2-apache

# Définit le répertoire racine d'Apache pour Symfony
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Mode développement (à commenter en production)
ENV APP_ENV=dev

# Installe les dépendances système
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libzip-dev \
    zip \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Configure les extensions PHP
RUN docker-php-ext-configure intl \
    && docker-php-ext-configure gd --with-jpeg --with-freetype \
    && docker-php-ext-install -j$(nproc) intl opcache pdo_mysql zip gd \
    && pecl install xdebug apcu \
    && docker-php-ext-enable xdebug apcu

# Active le rewrite Apache
RUN a2enmod rewrite

# Configuration PHP
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
COPY docker/config/opcache.ini "$PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini"
COPY docker/config/xdebug.ini "$PHP_INI_DIR/conf.d/99-xdebug.ini"

# Installe Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Installe Symfony CLI
RUN curl -sS https://get.symfony.com/cli/installer | bash \
    && mv /root/.symfony5/bin/symfony /usr/local/bin/symfony

# Définit le répertoire de travail et fixe les permissions
WORKDIR /var/www/html
RUN chown -R www-data:www-data /var/www/html

# Port exposé
EXPOSE 80