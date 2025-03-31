#!/bin/bash
set -e

# Installation Symfony si nécessaire
if [ "${INSTALL_SYMFONY}" = "true" ] && [ ! -f composer.json ]; then
    echo "Installing Symfony..."
    composer create-project symfony/skeleton . && \
    composer require symfony/webapp-pack
fi

# Permissions
chown -R www-data:www-data /var/www/html

exec "$@"