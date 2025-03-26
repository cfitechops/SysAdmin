# Créez le projet Symfony via Docker

```sh
docker-compose run --rm -v $(pwd)/symfonyapp:/var/www/html php-apache \
  composer create-project symfony/skeleton:"6.4.*" .
```

# Installez le pack webapp

```sh
docker-compose run --rm -v $(pwd)/symfonyapp:/var/www/html php-apache \
  composer require webapp
```

# Configurez la base de données

```sh
nano symfonyapp/.env
```

# Modifiez la ligne DATABASE_URL

```sh
DATABASE_URL="mysql://symfony_user:Cfitech63@@db:3306/cfitech_db?serverVersion=8.0"
```

# Initialisez la base

```sh
docker-compose exec -w /var/www/html php-apache php bin/console doctrine:database:create
docker-compose exec -w /var/www/html php-apache php bin/console doctrine:migrations:migrate
```

# Pour accéder à MySQL

```sh
docker-compose up -d --build
docker exec -it symfony-project-mysql mysql -u root -p
```