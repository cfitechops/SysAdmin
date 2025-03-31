```sh
docker-compose build
```

```sh
docker-compose run --rm app composer create-project symfony/skeleton:"6.4.*" symfonyapp --no-interaction
docker-compose run --rm --workdir=/var/www/html app composer require symfony/webapp-pack --no-interaction
docker-compose run --rm app chown -R www-data:www-data /var/www/html
docker-compose up -d
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
# Recréez la base de données
docker-compose exec -w /var/www/html app php bin/console doctrine:database:drop --force
docker-compose exec -w /var/www/html app php bin/console doctrine:database:create

# Supprimez les migrations existantes
docker-compose exec -w /var/www/html app rm -rf migrations/

# Recréez les migrations
docker-compose exec -w /var/www/html app mkdir migrations
docker-compose exec -w /var/www/html app php bin/console make:migration
docker-compose exec -w /var/www/html app php bin/console doctrine:migrations:migrate -n
```
