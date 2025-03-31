FROM php:8.2-apache

# Configuration Apache
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf && \
    echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    a2enmod rewrite

# Installation des dépendances
RUN apt-get update && \
    apt-get install -y \
        libicu-dev \
        libzip-dev \
        unzip \
        git && \
    docker-php-ext-install pdo pdo_mysql intl zip opcache && \
    pecl install xdebug && \
    docker-php-ext-enable xdebug pdo_mysql

# Installation de Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Script d'installation
COPY docker/install_symfony.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/install_symfony.sh

# Dossiers de base
RUN mkdir -p /var/www/html/public && \
    chown -R www-data:www-data /var/www/html

WORKDIR /var/www/html

ENTRYPOINT ["install_symfony.sh"]

CMD ["apache2-foreground"]