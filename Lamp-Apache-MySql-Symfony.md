#### Installation de LAMP (Linux, Apache, MySQL, PHP)

- Mise à jour du système et installation des paquets de base

```sh
sudo apt update && sudo apt upgrade -y
```     

- Installation des paquets LAMP 

```sh
sudo apt install apache2 php libapache2-mod-php mysql-server php-mysql -y
```

- Installation des modules PHP supplémentaires

```sh
sudo apt install php-cli php-xml php-mbstring php-intl php-json php-curl php-zip -y
```

- Test de PHP avec phpinfo
  - Création du fichier info.php

```sh
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php
```

- Redémarrage d'Apache

```sh
sudo systemctl restart apache2
```

- Configuration de MySQL
  - Édition du fichier de configuration MySQL

```sh
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

- Ajout de la configuration du socket (si nécessaire)

```sh
[mysqld]
socket = /var/run/mysqld/mysqld.sock
```

- Connexion à MySQL
  - Se connecte à MySQL en tant qu'utilisateur root.

```sh
sudo mysql -u root
```

- Création de la base de données et de l'utilisateur

```sh
CREATE DATABASE cfitech_db;
CREATE USER 'cfitech_user'@'localhost' IDENTIFIED BY 'infotech63@';
GRANT ALL PRIVILEGES ON cfitech_db.* TO 'cfitech_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

- Test de connexion MySQL avec un script PHP
  - Création du fichier db_test.php

```sh
echo '<?php
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
?>' | sudo tee /var/www/html/db_test.php
```

- Accès au script

  - Ouvrez un navigateur et accédez à **http://localhost/db_test.php** pour vérifier la connexion.

- Configuration d'Apache
  - Ajout de ServerName dans la configuration Apache pour éviter les avertissements.

```sh
echo "ServerName localhost" | sudo tee -a /etc/apache2/apache2.conf
echo "ServerName localhost" | sudo tee -a /etc/apache2/sites-available/000-default.conf
```

- Vérification de la configuration Apache

```sh
sudo apachectl configtest
```

- Redémarrage d'Apache

```sh
sudo systemctl restart apache2
```

- Vérification du statut d'Apache

```sh
sudo systemctl status apache2
```

#### Installation de Symfony

- Installation de Composer

```sh
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
composer --version
```

- Installation de Symfony CLI

```sh
curl -sS https://get.symfony.com/cli/installer | bash
sudo mv /home/symfony/.symfony5/bin/symfony /usr/local/bin/symfony
export PATH="$HOME/.symfony5/bin:$PATH"
source ~/.bashrc
symfony -V
```

#### Installation et configuration de Git

- Installation de Git

```sh
sudo apt install -y git
```

- Configuration de Git

```sh
git config --global user.email "votre@email.com"
git config --global user.name "Votre Nom"
```

- Génération d'une clé SSH pour GitHub

```sh
ssh-keygen -t ed25519 -C "votre@email.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

- Affichage de la clé publique (à copier dans GitHub)

```sh
cat ~/.ssh/id_ed25519.pub
```

- Test de la connexion SSH à GitHub

```sh
ssh -T git@github.com
```

- Création d'un projet Symfony

```sh
symfony new mon_projet_symfony --webapp
cd mon_projet_symfony
symfony server:start -d
```

- Configuration d'Apache pour Symfony

```sh
echo '<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /home/symfony/mon_projet_symfony/public
    ServerName mon_projet_symfony.local

    <Directory "/home/symfony/mon_projet_symfony/public">
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>' | sudo tee /etc/apache2/sites-available/mon_projet_symfony.conf
```

- Activation du site et redémarrage d'Apache

```sh
sudo a2ensite mon_projet_symfony.conf
sudo a2enmod rewrite
sudo systemctl restart apache2
```

- Ajout du nom de domaine local

```sh
echo "127.0.0.1 localhost mon_projet_symfony.local" | sudo tee -a /etc/hosts
```

- Configuration de la base de données Symfony

```sh
sed -i 's|DATABASE_URL=".*"|DATABASE_URL="mysql://root:infotech63@@127.0.0.1:3306/symfony_db?serverVersion=5.7&charset=utf8mb4"|' .env
```

- Création de la base de données

```sh
php bin/console doctrine:database:create
php bin/console doctrine:migrations:migrate
```

- Installation des dépendances supplémentaires pour Symfony

```sh
sudo apt install -y php8.1-xml php8.1-bcmath php8.1-intl php8.1-mbstring php8.1-mysql php8.1-common php8.1-curl php8.1-gmp php8.1-fpm php8.1-zip unzip
```

- Configuration des permissions

```sh
sudo chown -R $USER:$USER /var/www/html
sudo chmod -R 755 /var/www/html
sudo chown -R $USER:$USER /home/symfony/mon_projet_symfony
sudo chmod -R 777 /home/symfony/mon_projet_symfony/var/
sudo chmod -R 777 /home/symfony/mon_projet_symfony/public/
```

- Vérification des services

```sh
sudo systemctl status apache2
sudo systemctl status mysql
```
