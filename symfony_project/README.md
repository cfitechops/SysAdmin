nano Dockerfile

```sh
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
```

nano docker-compose.yml

```sh
version: "3.8"

services:
  app:
    build: .
    volumes:
      - ./symfonyapp:/var/www/html
    ports:
      - "8080:80"
    environment:
      - APP_ENV=dev
      - INSTALL_SYMFONY=${INSTALL_SYMFONY:-true}
    networks:
      - symfony_network
    depends_on:
      db:
        condition: service_healthy

  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
      MYSQL_DATABASE: ${DB_NAME}
      MYSQL_USER: ${DB_USER}
      MYSQL_PASSWORD: ${DB_PASSWORD}
      MYSQL_ROOT_HOST: "%"
    volumes:
      - db_data:/var/lib/mysql
    networks:
      - symfony_network
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-u${DB_USER}", "-p${DB_PASSWORD}"]
      interval: 5s
      timeout: 10s
      retries: 5

volumes:
  db_data:

networks:
  symfony_network:
    driver: bridge
    attachable: true
```

nano .env

```sh
# Docker
INSTALL_SYMFONY=true

# Database
DB_ROOT_PASSWORD=rootpass
DB_NAME=cfitech_db
DB_USER=symfony
DB_PASSWORD=symfony
DATABASE_URL="mysql://${DB_USER}:${DB_PASSWORD}@db:3306/${DB_NAME}?serverVersion=8.0"

# Symfony
APP_ENV=dev
```

nano docker/install_symfony.sh

```sh
#!/bin/bash
set -e

# Installation Symfony
if [ "${INSTALL_SYMFONY}" = "true" ] && [ ! -f composer.json ]; then
    echo "Installing Symfony..."
    composer create-project symfony/skeleton . && \
    composer require symfony/webapp-pack
fi

# Permissions
chown -R www-data:www-data /var/www/html

exec "$@"
```

nano docker/config/php.ini

```sh
[PHP]
opcache.enable=1
memory_limit=256M
upload_max_filesize=64M
post_max_size=64M
```

nano docker/config/xdebug.ini

```sh
[xdebug]
xdebug.mode=develop,debug
xdebug.start_with_request=trigger
xdebug.client_host=host.docker.internal
```

# ======================================

```sh
docker-compose build
```

```sh
docker-compose run --rm app composer create-project symfony/skeleton:"6.4.*" symfonyapp --no-interaction
docker-compose run --rm --workdir=/var/www/html app composer require symfony/webapp-pack --no-interaction
docker-compose run --rm app chown -R www-data:www-data /var/www/html
```

```sh
docker-compose up -d
```

```sh
sudo nano symfonyapp/.env
```

```sh
# Surcharge des valeurs pour le développement local
DATABASE_URL="mysql://symfony:symfony@db:3306/cfitech_db?serverVersion=8.0"
APP_DEBUG=1
```

```sh
# Drop and recreate database
docker-compose exec -w /var/www/html app php bin/console doctrine:database:drop --force
docker-compose exec -w /var/www/html app php bin/console doctrine:database:create

# Regenerate migrations
docker-compose exec -w /var/www/html app rm -rf migrations/
docker-compose exec -w /var/www/html app mkdir migrations
docker-compose exec -w /var/www/html app php bin/console make:migration
docker-compose exec -w /var/www/html app php bin/console doctrine:migrations:migrate -n
```
