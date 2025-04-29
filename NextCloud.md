# Nextcloud

- [Nextcloud](https://nextcloud.com/) est une plateforme collaborative auto-hébergée conçue pour améliorer la productivité grâce à des services intégrés comme Fichiers, Talk, Groupware et Office. Elle offre des fonctionnalités similaires à celles de Dropbox, Office 365 ou Google Drive lorsqu'elle est utilisée avec des suites bureautiques comme Collabora Online ou OnlyOffice.

- Nextcloud propose quatre produits principaux :

  - [Fichiers](https://nextcloud.com/files/) : stockage et synchronisation de fichiers
  - [Talk](https://nextcloud.com/talk/) : conférences audio/vidéo privées
  - [Groupware](https://nextcloud.com/groupware/) : calendrier, contacts et mail
  - [Office](https://nextcloud.com/office/) : suite bureautique en ligne

- Nextcloud peut être hébergé dans le cloud ou sur site, offrant ainsi des options de déploiement flexibles. Il permet de stocker des documents sur des serveurs privés ou des centres de données de confiance, garantissant ainsi un contrôle et une sécurité accrus.

- Vous trouverez ci-dessous un guide étape par étape expliquant comment installer NextCloud sur Ubuntu 24.04 LTS.

#### Étape 1 : Mettre à jour et mettre à niveau le système

- Avant l'installation de nextcloud, nous ferions mieux de mettre à jour tous les packages système et de mettre à niveau le système vers la dernière version. Pour mettre à jour et mettre à niveau en un seul coup, veuillez exécuter la commande suivante.

```sh
sudo -i
apt update -y && apt upgrade -y
```

#### Étape 2 : installer Apache et MySQL Server

- Nextcloud est une application Web avec un back-end de base de données, nous avons donc besoin d'un serveur Web et d'un serveur de base de données pour l'installation, nous installons Apache comme serveur Web et MariaDB comme serveur de base de données.

- Installation du serveur Apache :

```sh
apt install apache2 -y
```

- Démarrer et activer le service Apache :

```sh
systemctl start apache2
systemctl enable apache2
```

- Consultez l'état actuel du serveur Apache avec la commande ci-dessous, le serveur Apache doit être en cours d'exécution.

```sh
systemctl status apache2
```

- Installation du serveur MariaDB

```sh
apt install mariadb-server
```

- Démarrer et activer le service MariaDB

```sh
systemctl start mariadb
systemctl enable mariadb
```

- Vérifiez l'état actuel du serveur MariaDB avec la commande ci-dessous, le service MariaDB doit être en cours d'exécution.

```sh
systemctl status mariadb
```

#### Étape 3 : Installer PHP et les modules de support

- Nextcloud est écrit en PHP et JavaScript, nous avons donc dû installer PHP et tous les modules requis pour que ses fonctionnalités fonctionnent correctement.

- Installer PHP et les modules requis :

```sh
apt install php php-common libapache2-mod-php php-bz2 php-gd php-mysql \
php-curl php-mbstring php-imagick php-zip php-common php-curl php-xml \
php-json php-bcmath php-xml php-intl php-gmp zip unzip wget
```

- Activer les modules PHP sur Apache.

```sh
a2enmod env rewrite dir mime headers setenvif ssl
```

- Maintenant, redémarrez Apache pour charger tous les modules PHP installés

```sh
systemctl restart apache2
```

- Vérifiez que les modules sont chargés sur Apache.

```sh
root@nextcloud:~# apache2ctl -M
Loaded Modules:
 core_module (static)
 so_module (static)
 watchdog_module (static)
 http_module (static)
 log_config_module (static)
 logio_module (static)
 version_module (static)
...........
```

#### Étape 4 : Créer la base de données et l’utilisateur Nextcloud

- Dans cette étape, nous allons créer une base de données et un utilisateur de base de données pour Nextcloud.

- Connectez-vous à l'invite MySQL, tapez simplement la commande ci-dessous, elle ouvrira une invite MariaDB interactive pour créer un utilisateur et une base de données.

```sh
mysql
```

- Créez maintenant une base de données MySQL et un utilisateur pour Nextcloud, puis accordez-lui les autorisations d'accès à la base de données. Copiez toutes les commandes SQL et exécutez-les une par une à l'invite.

```sh
MariaDB [(none)]> CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY 'nextcloud@123';
MariaDB [(none)]> CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
MariaDB [(none)]> GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'localhost';
MariaDB [(none)]> FLUSH PRIVILEGES;
MariaDB [(none)]> quit;
```

#### Étape 5 : Décompressez l'archive Nextcloud et configurez-la

- Téléchargez maintenant la dernière archive Nextcloud. Accédez à la [page de téléchargement Nextcloud](https://nextcloud.com/install/). . Vous pouvez également la télécharger depuis ce [lien direct .](https://download.nextcloud.com/server/releases/latest.zip)

- Téléchargez et décompressez dans le dossier racine Web `/var/www/html` :

```sh
cd /var/www/html
```

- Supprimez le fichier index.html par défaut de la racine Web :

```sh
rm index.html
```

- Téléchargez et décompressez l'archive Nextcloud :

```sh
wget https://download.nextcloud.com/server/releases/latest.zip
unzip latest.zip
```

- Déplacez tout le contenu Nextcloud vers le dossier racine Web (/var/www/html) :

```sh
cd /var/www/html/nextcloud
mv * /var/www/html/
```

- Supprimer le dossier nextcloud vide

```sh
rmdir /var/www/html/nextcloud
```

- Modifiez la propriété du répertoire de contenu Nextcloud à l'utilisateur HTTP.

```sh
chown -R www-data:www-data /var/www/html
```

#### Étape 6 : Terminer l’installation de Nextcloud

- Maintenant, allez dans le navigateur et tapez `http:// [ ip ou fqdn ]` du serveur. La page d'installation de Nextcloud ci-dessous s'affichera.

- Sur cette page, nous devons fournir des informations pour

- 1 - Nom d'utilisateur et mot de passe de l'administrateur Nextcloud
- 2 - Informations d'identification de la base de données (nom de la base de données, utilisateur de la base de données et mot de passe de la base de données)
- 3 - Après avoir fourni toutes les informations, cliquez sur le bouton `Installer`

![nextcloud](/assets/nextcloud_01.png)

- Une fois l'installation de Nextcloud terminée, la page des applications recommandées s'affichera. Cliquez sur le bouton **Installer les applications recommandées** .

![nextcloud](/assets/nextcloud_02.png)

- il faudra 1/2 minute pour installer toutes les applications recommandées, puis le tableau de bord d'administration s'affichera.

![nextcloud](/assets/nextcloud_03.png)

- avec le tableau de bord d'administration qui s'affiche, notre installation Nextcloud sur Ubuntu 24.04 se termine avec succès 🤗

#### Domaine non approuvé. Nous devons donc effectuer quelques configurations sur le serveur.

```sh
nano /var/www/html/config/config.php
```

```sh
<?php
$CONFIG = array (
  'instanceid' => 'oc3w93pwyw2t',
  'passwordsalt' => '4DfAo/pgLdmDGCqBnQ1GxB7k3Jq44x',
  'secret' => 'HeILH3cjb/SnN1wiAapX+PsACaQnu8sZr/tQNIWrXeiyClSS',
  'trusted_domains' =>
  array (
    0 => 'localhost',
    1 => '192.168.129.20',
  ),
  'datadirectory' => '/var/www/html/data',
  'dbtype' => 'mysql',
  'version' => '31.0.4.1',
  'overwrite.cli.url' => 'http://192.168.129.20',
  'dbname' => 'nextcloud',
  'dbhost' => 'localhost',
  'dbport' => '',
  'dbtableprefix' => 'oc_',
  'mysql.utf8mb4' => true,
  'dbuser' => 'nextcloud',
  'dbpassword' => 'nextcloud@123',
  'installed' => true,
);
```
