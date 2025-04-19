# Installer NextCloud à partir de la ligne de commande

- Dans ce guide, nous vous montrerons comment installer NextCloud en ligne de commande sur Ubuntu 22.04. Au lieu d'utiliser l'installation web, nous exécuterons quelques commandes pour finaliser les configurations initiales. Nous n'effectuerons donc pas l'installation manuellement.

- Il existe différentes méthodes d' installation de [Nextcloud.](https://nextcloud.com/). L'installation en ligne de commande est la plus simple. Nous allons d'abord préparer l'environnement serveur pour une installation standard de Nextcloud. Ensuite, au lieu d'une installation en ligne de commande, nous installerons et configurerons Nextcloud sur Ubuntu 22.04.

- La méthode d'installation de Nextcloud en ligne de commande est très utile, car elle permet une installation entièrement automatique avec n'importe quel système d'automatisation. Les étapes d'installation de Nextcloud en ligne de commande sont détaillées ci-dessous.

#### Table des matières

- Étape 1 : Installer PHP, Apache et MariaDB Server
- Étape 2 : Configurer le serveur MariaDB
- Étape 3 : Télécharger et préparer le package Nextcloud
- Étape 4 : Exécutez la commande CLI d'installation de Nextcloud

#### Étape 1 : Installer PHP, Apache et MariaDB Server

- 1 - Mettre à jour et mettre à niveau les packages Ubuntu

```sh
apt update && apt upgrade
```

- 2 - installer Apache et MySQL Server

```sh
apt install apache2 mariadb-server
```

- 3 - Installez PHP et les autres dépendances et redémarrez Apache

```sh
apt install libapache2-mod-php php-bz2 php-gd php-mysql php-curl php-mbstring \
php-imagick php-zip php-ctype php-curl php-dom php-json php-posix php-bcmath \
php-xml php-intl php-gmp zip unzip wget
```

- 4 - Activez les modules Apache requis et redémarrez Apache

```sh
a2enmod rewrite dir mime env headers
systemctl restart apache2
```

#### Étape 2 : Configurer le serveur MariaDB

- 1 - Connectez-vous à l'invite MySQL, tapez simplement

```sh
mysql
```

- 2 - Créez une base de données MySQL et un utilisateur pour Nextcloud et fournissez des autorisations.

```sh
CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY 'passw@rd';
CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'localhost';
FLUSH PRIVILEGES;
quit;
```

#### Étape 3 : Télécharger et préparer le package Nextcloud

Téléchargez maintenant la dernière archive Nextcloud. Accédez à la [page de téléchargement Nextcloud](https://nextcloud.com/install/). Vous pouvez également la télécharger depuis ce [lien direct](https://download.nextcloud.com/server/releases/latest.zip).

- 1 - Téléchargez et décompressez le dossier racine Web (/var/www/html)

```sh
cd /var/www/html
wget https://download.nextcloud.com/server/releases/latest.zip
unzip latest.zip
```

- 2 - Déplacez tout le contenu de nextcloud vers le dossier racine Web (/var/www/html)

```sh
cd /var/www/html/nextcloud
mv * .* ../
```

- 3 - Supprimez le répertoire nextcloud vide

```sh
rmdir /var/www/html/nextcloud
```

- 4 - Modifiez la propriété du répertoire de contenu nextcloud en l'attribuant à l'utilisateur HTTP.

```sh
chown -R www-data:www-data /var/www/html
```

#### Étape 4 : Exécutez la commande CLI d'installation de Nextcloud

- Cette commande CLI prendra tous les paramètres d'installation tels que la base de données et les informations d'identification de l'administrateur pour exécuter l'installation et la configuration en arrière-plan.

```sh
cd /var/www/html
sudo -u www-data php occ  maintenance:install --database \
"mysql" --database-name "nextcloud"  --database-user "nextcloud" --database-pass \
"passw@rd" --admin-user "admin" --admin-pass "admin123"
```

- Si tout se passe bien, la commande affichera `Nextcloud a été installé avec succès` .

- nextcloud n'autorise l'accès qu'à partir de localhost, cela pourrait se produire via l'erreur `Accès via un domaine non approuvé` . Nous devons autoriser l'accès à nextcloud en utilisant notre adresse IP ou notre nom de domaine.

```sh
vi /var/www/html/config/config.php
```

```sh
<?php
$CONFIG = array (
  'passwordsalt' => 'VAXFa5LsahAWHK/CMPHC3QkTsnqK80',
  'secret' => 'ZWTuZMLpKVizET85i/NkcwYCPUQyjB/6ZjEYGdVgJeDhNXzR',
  'trusted_domains' =>
  array (
    0 => 'localhost',
    1 => 'nc.cfitech.be', // we added this line
  ),
  'datadirectory' => '/var/www/html/data',
  'dbtype' => 'mysql',
  .....

:x    // Now, save the file and restart apache2
```

```sh
systemctl restart apache2
```

- Maintenant, allez dans le navigateur et tapez `http:// [ip ou fqdn]` du serveur, une fois la configuration terminée en ligne de commande, la page de connexion apparaîtra.
