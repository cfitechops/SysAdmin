## Installation de LAMP

- Mise à jour et installation des paquets nécessaires

```sh
sudo apt update && sudo apt upgrade -y
sudo apt install apache2 php libapache2-mod-php mysql-server php-mysql -y
```

- Installation des modules PHP supplémentaires (requis pour Symfony et autres projets modernes).

```sh
sudo apt install php-cli php-xml php-mbstring php-intl php-json php-curl php-zip -y
```

#### Test de PHP avec phpinfo

- Créez le fichier /var/www/html/info.php

```sh
sudo nano /var/www/html/info.php
```

- Contenu du fichier

```sh
<?php
phpinfo();
?>
```

- Accédez à [http://localhost/info.php.](http://localhost/info.php) dans un navigateur pour vérifier que PHP fonctionne correctement.

- Redémarrage d'Apache après modification

```sh
sudo systemctl restart apache2
```

#### Configuration de MySQL

- Connectez-vous à MySQL en tant que root

```sh
sudo mysql -u root -p
```

```sh
CREATE DATABASE cfitech_db;
CREATE USER 'cfitech_user'@'localhost' IDENTIFIED BY 'infotech63@';
GRANT ALL PRIVILEGES ON cfitech_db.* TO 'cfitech_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

#### Test de connexion MySQL avec un script PHP

- Créez le fichier /var/www/html/db_test.php

```sh
sudo nano /var/www/html/db_test.php
```

- Contenu du fichier

```sh
<?php
$servername = "localhost";
$username = "cfitech_user";
$password = "infotech63@";
$dbname = "cfitech_db";

// Création de la connexion
$conn = new mysqli($servername, $username, $password, $dbname);

// Vérification de la connexion
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
echo "Connected successfully";
?>
```

- Accédez à [http://localhost/db_test.php.](http://localhost/db_test.php) pour vérifier que la connexion fonctionne.

#### Configuration d'Apache

- Ajoutez ServerName localhost dans le fichier Apache principal

```sh
sudo nano /etc/apache2/apache2.conf
```

- Ajoutez cette ligne à la fin du fichier

```sh
ServerName localhost
```

- Modifiez le VirtualHost par défaut si nécessaire

```sh
sudo nano /etc/apache2/sites-available/000-default.conf
```

- Ajoutez ou modifiez cette ligne si elle n'existe pas

```sh
ServerName localhost
```

- Testez la configuration Apache

```sh
sudo apachectl configtest
```

- Redémarrez Apache

```sh
sudo systemctl restart apache2
```

- Vérifiez le statut d'Apache pour vous assurer qu'il fonctionne correctement

```sh
sudo systemctl status apache2
```

## Installation de Symfony

- Installez Composer (gestionnaire de dépendances PHP)

```sh
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
composer --version  # Vérifiez que Composer est installé.
```

- Installez Symfony CLI (outil pour gérer les projets Symfony)

```sh
curl -sS https://get.symfony.com/cli/installer | bash
sudo mv /home/$(whoami)/.symfony*/bin/symfony /usr/local/bin/symfony
symfony --version  # Vérifiez que Symfony CLI est installé.
```

- Créez un nouveau projet Symfony avec l'environnement webapp préconfiguré

```sh
symfony new mon_projet_symfony --webapp
cd mon_projet_symfony
symfony server:start  # Démarrez le serveur Symfony local.
```

#### Configuration d'Apache pour Symfony

- Créez un VirtualHost spécifique pour votre projet Symfony

```sh
sudo nano /etc/apache2/sites-available/mon_projet_symfony.conf
```

- Contenu du fichier

```sh
<VirtualHost *:80>
    ServerAdmin webmaster@localhost

    DocumentRoot /home/lamp/mon_projet_symfony/public

    ServerName mon_projet_symfony.local

    <Directory "/home/lamp/mon_projet_symfony/public">
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

- Activez le site et le module rewrite d’Apache (nécessaire pour Symfony)

```sh
sudo a2ensite mon_projet_symfony.conf
sudo a2enmod rewrite
sudo systemctl restart apache2
```

- Ajoutez une entrée dans /etc/hosts pour résoudre mon_projet_symfony.local

```sh
sudo nano /etc/hosts
```

- Ajoutez cette ligne à la fin du fichie

```sh
127.0.0.1 localhost mon_projet_symfony.local
```

- Accédez à [http://mon_projet_symfony.local.](http://mon_projet_symfony.local) dans votre navigateur

#### Configuration de la base de données Symfony

- Modifiez le fichier **.env** dans le dossier du projet Symfony pour configurer l'accès à la base de données MySQL

```sh
nano .env
```

- Modifiez la ligne suivante avec vos informations MySQL

```sh
DATABASE_URL="mysql://root:infotech63@@127.0.0.1:3306/symfony_db?serverVersion=5.7&charset=utf8mb4"
```

- Créez la base de données Symfony avec Doctrine

```sh
php bin/console doctrine:database:create
php bin/console doctrine:migrations:migrate
```

#### Note:

- Un serveur LAMP fonctionnel, un projet Symfony configuré avec Apache, et une base de données MySQL.
