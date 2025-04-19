# Installer NextCloud sur Ubuntu 22.04 LTS – Guide complet

- [Nextcloud](https://nextcloud.com/) est un système d'hébergement de fichiers qui nous permet de stocker notre contenu comme des documents, des images, des vidéos, etc., et de le partager avec d'autres.

- Au lieu de dépendre de prestataires de services externes pour nos documents personnels et professionnels, Nextcloud nous donne la liberté de les stocker sur nos serveurs ou dans des centres de données de confiance. Il s'agit d'un système centralisé de gestion de documents et de fichiers autogéré.

- Cette configuration détaillée vous permettra d'optimiser les performances de NextCloud et d'appliquer toutes les mesures de sécurité nécessaires pour sécuriser le serveur.

- Vous trouverez ci-dessous des instructions détaillées pour installer Nextcloud sur Ubuntu 22.04 LTS. Pour garantir des performances et une sécurité optimales, nous avons ajouté les étapes nécessaires à l'ajout de fonctionnalités supplémentaires au système. Chaque étape est fortement recommandée pour configurer un environnement Nextcloud de production

#### Table des matières

- **Étape 1**. installer les packages requis
- **Étape 2**. Configurer le serveur MySQL
- **Étape 3**. Téléchargez, extrayez et appliquez les autorisations.
- **Étape 4**. Installer NextCloud depuis la ligne de commande
- **Étape 5**. Installer et configurer PHP-FPM avec Apache
- **Étape 6**. Créer une page info.php pour vérifier les fonctionnalités PHP
- **Étape 7**. Activer Opcache en PHP
- **Étape 8**. Activer APCu en PHP
- **Étape 9**. Installer et configurer Redis
- **Étape 10**. Installer SSL et activer HTTP2
- **Étape 11**. URL élégantes

#### Étape 1 : installer les packages requis

- 1 - Mettre à jour et mettre à niveau les packages Ubuntu

```sh
apt update -y && apt upgrade -y
```

- 2 - installer Apache et MySQL Server

```sh
apt install apache2 mariadb-server
```

- 3 - Installez PHP et les autres dépendances et redémarrez Apache

```sh
apt install libapache2-mod-php php-bz2 php-gd php-mysql php-curl php-zip \
php-mbstring php-imagick php-ctype php-curl php-dom php-json php-posix \
php-bcmath php-xml php-intl php-gmp zip unzip wget
```

- 4 - Activez les modules Apache requis et redémarrez Apache

```sh
a2enmod rewrite dir mime env headers
systemctl restart apache2
```

#### Étape 2. Configurer le serveur MySQL

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

#### Étape 3. Téléchargez, extrayez et appliquez les autorisations.

- Téléchargez maintenant la dernière archive Nextcloud. Accédez à la [page de téléchargement Nextcloud.](https://nextcloud.com/install/). Vous pouvez également la télécharger directement depuis le lien : [https://download.nextcloud.com/server/releases/latest.zip](https://download.nextcloud.com/server/releases/latest.zip)

- 1 - Téléchargez et décompressez dans le dossier /var/www

```sh
cd /var/www/
wget https://download.nextcloud.com/server/releases/latest.zip
unzip latest.zip
```

- 2 - Supprimez le fichier zip, qui n'est plus nécessaire maintenant.

```sh
rm -rf latest.zip
```

- 3 - Modifiez la propriété du répertoire de contenu nextcloud en l'attribuant à l'utilisateur HTTP.

```sh
chown -R www-data:www-data /var/www/nextcloud/
```

#### Étape 4. Installer NextCloud depuis la ligne de commande

- Nous allons installer Nextcloud sur Ubuntu 22.04 en ligne de commande. Cela nous fera gagner du temps, car nous fournirons toutes les informations d'identification de base de données et d'administrateur nécessaires à l'installation. L'installation de Nextcloud se fera en mode silencieux, sans configuration web. Pour une installation détaillée de Nextcloud en ligne de commande, consultez cette [page.](https://github.com/cfitechops/SysAdmin/blob/main/NextCloud-0.md).

- 1 - Exécutez la commande CLI

```sh
cd /var/www/nextcloud

sudo -u www-data php occ  maintenance:install --database \
"mysql" --database-name "nextcloud"  --database-user "nextcloud" --database-pass \
"passw@rd" --admin-user "admin" --admin-pass "admin123"
```

- Si tout se passe bien, la commande affichera `Nextcloud a été installé avec succès`. Nous avons fourni un nom d'utilisateur/mot de passe très simple. Lors de la configuration de la production, il doit s'agir d'un mot de passe complexe.

- 2 - nextcloud autorise l'accès uniquement à partir de localhost, cela pourrait entraîner une erreur `Accès via un domaine non approuvé`. nous devons autoriser l'accès à nextcloud en utilisant l'adresse IP ou le nom de domaine.

````sh
```sh
vi /var/www/nextcloud/config/config.php
````

```sh
  'trusted_domains' =>
  array (
    0 => 'localhost',
    1 => 'nc.cfitech.be',   // we Included the Sub Domain
  ),
  .....
:x    // saving the file
```

- 3 - Configurez Apache pour charger Nextcloud à partir du dossier /var/www/nextcloud .

```sh
vi /etc/apache2/sites-enabled/000-default.conf
```

```sh
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/nextcloud
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>

:x
```

- Maintenant, redémarrez le serveur Apache

```sh
systemctl restart apache2
```

- Maintenant, accédez au navigateur et tapez `http:// [ip ou fqdn]` du serveur. La page de connexion Nextcloud ci-dessous apparaîtra.

- L'installation de base de NextCloud sur Ubuntu 22.04 est terminée, nous allons maintenant travailler sur les performances et la sécurité.

#### Étape 5. Installer et configurer PHP-FPM avec Apache

- Ici, nous allons installer PHP-FPM, qui est plus rapide que le module mpm-prefork, qui est la méthode par défaut d'exécution des fichiers php sur Apache.

- 1 - Installer php-fpm

```sh
apt install php8.1-fpm
service php8.1-fpm status
```

- 2 - Vérifiez la version de php-fpm et Socket.

```sh
php-fpm8.1 -v
ls -la /var/run/php/php8.1-fpm.sock
```

- 3 - Désactiver le module Apache prefork

```sh
a2dismod php8.1
a2dismod mpm_prefork
```

- 4 - Activer php-fpm

```sh
a2enmod mpm_event proxy_fcgi setenvif
a2enconf php8.1-fpm
```

- 5 - définir les variables php.ini requises

```sh
vi /etc/php/8.1/fpm/php.ini
```

```sh
upload_max_filesize = 64M
post_max_size = 96M
memory_limit = 512M
max_execution_time = 600
max_input_vars = 3000
max_input_time = 1000

:x
```

- 6 - Configurations du pool php-fpm

```sh
vi /etc/php/8.1/fpm/pool.d/www.conf

pm.max_children = 64
pm.start_servers = 16
pm.min_spare_servers = 16
pm.max_spare_servers = 32

:x
```

```sh
service php8.1-fpm restart
```

- 7 - Directives Apache pour le traitement des fichiers PHP par PHP-FPM

```sh
vi /etc/apache2/sites-enabled/000-default.conf
```

```sh
<VirtualHost *:80>

	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/nextcloud

	<Directory /var/www/nextcloud>
          Options Indexes FollowSymLinks
          AllowOverride All
          Require all granted
	</Directory>

	<FilesMatch ".php$">
         SetHandler "proxy:unix:/var/run/php/php8.1-fpm.sock|fcgi://localhost/"
	</FilesMatch>

	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>

:x   // Save the File
```

```sh
service apache2 restart
```

#### Étape 6. Créer une page info.php pour vérifier les fonctionnalités PHP

- Créez une page info.php, elle nous montrera si php-fpm, opcache, apcu sont activés avec le php.

```sh
cd /var/www/nextcloud
```

```sh
vi info.php
```

```sh
<?php phpinfo(); ?>
```

```sh
:x
```

- Parcourez maintenant `http://nc.cfitech.be/info.php`. , il affichera `Server API FPM/FastCGI` si le php-fpm est activé sur PHP

#### Étape 7. Activer Opcache en PHP

- Opcache est un moteur de mise en cache pour PHP. Il stocke le bytecode des scripts précompilés en mémoire partagée, évitant ainsi l'analyse des scripts PHP à chaque requête. Il améliore les performances d'exécution des fichiers PHP et de chargement des sites web.

```sh
vi /etc/php/8.1/fpm/php.ini
```

```sh
opcache.enable=1
opcache.enable_cli=1
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=10000
opcache.memory_consumption=128
opcache.save_comments=1
opcache.revalidate_freq=60
```

```sh
:x
```

- Maintenant, redémarrez Apache et PHP-FPM

```sh
systemctl restart php8.1-fpm
systemctl restart apache2
```

- Maintenant, vérifiez à nouveau `http://nc.cfitech.be/info.php` , il affichera « Opcache est opérationnel »

#### Étape 8. Activer APCu en PHP

- APCu est un cache de données utilisateur. Il s'agit d'un cache local pour les systèmes. Nextcloud l'utilise pour la mise en cache mémoire.

- 1 - Installer APCu

```sh
apt install php8.1-apcu
```

- 2 - Configurez Nextcloud pour utiliser APCu pour la mise en cache de la mémoire.

```sh
vi /var/www/nextcloud/config/config.php
```

```sh
'memcache.local' => '\OC\Memcache\APCu',
```

```sh
:x
```

- Redémarrer php-fpm et apache

```sh
systemctl restart php8.1-fpm
systemctl restart apache2
```

- Maintenant, vérifiez à nouveau `http://nc.cfitech.be/info.php` , il affichera « Support APCu activé »

#### Étape 9. Installer et configurer Redis

- Dans Nextcloud, Redis est utilisé pour la mise en cache locale et distribuée, ainsi que pour le verrouillage des fichiers transactionnels. Nous avons utilisé APCu pour la mise en cache locale, plus rapide que Redis. Nous utiliserons Redis pour le verrouillage des fichiers. Le mécanisme de verrouillage transactionnel des fichiers de Nextcloud verrouille les fichiers afin d'éviter leur corruption en fonctionnement normal.

- 1 - Installez Redis Server et l'extension PHP Redis

```sh
apt-get install redis-server php-redis
```

- Démarrer et activer Redis

```sh
systemctl start redis-server
systemctl enable redis-server
```

- 2 - Configurer Redis pour utiliser les ports Unix Socket

```sh
vi /etc/redis/redis.conf
```

```sh
port 0
unixsocket /var/run/redis/redis.sock
unixsocketperm 770
```

```sh
:x
```

- 3 - Ajouter l'utilisateur Apache au groupe Redis

```sh
usermod -a -G redis www-data
```

- 4 - Configurer Nextcloud pour utiliser Redis pour le verrouillage de fichiers

```sh
vi /var/www/nextcloud/config/config.php
```

```sh
'filelocking.enabled' => 'true',
'memcache.locking' => '\OC\Memcache\Redis',
'redis' => [
     'host'     => '/var/run/redis/redis.sock',
     'port'     => 0,
     'dbindex'  => 0,
     'password' => '',
     'timeout'  => 1.5,
],
```

```sh
:x
```

- 5 - Activer le verrouillage de session Redis en PHP

```sh
vi /etc/php/8.1/fpm/php.ini
```

```sh
redis.session.locking_enabled=1
redis.session.lock_retries=-1
redis.session.lock_wait_time=10000
```

```sh
:x
```

- Maintenant, redémarrez php-fpm et apache

```sh
systemctl restart php8.1-fpm
systemctl restart apache2
```

- Maintenant, nous pouvons vérifier l'utilisation de Redis (en activant le port Redis dans la configuration Redis) en exécutant la commande `redis-cli MONITOR`, pendant le chargement de Nextcloud, il affichera les données en direct sur l'écran.

- Maintenant que nous avons terminé les étapes d'amélioration des performances, nous allons nous concentrer sur la sécurité. Tout d'abord, nous allons installer un certificat SSL pour Nextcloud.

#### Étape 10. Installer SSL et activer HTTP2

- 1 - Nous allons installer le certificat LetsEncrypt, nous avons donc d'abord besoin des outils Certbot.

```sh
apt-get install python3-certbot-apache -y
```

- 2 - avec l'outil Certbot, demandons un certificat pour notre domaine.

```sh
certbot --apache -d nc.cfitech.be
```

- Veuillez suivre l'image, fournir votre e-mail et accepter les conditions pour générer le SSL

```sh

```

- 3 - Activez le module Apache HTTP2 et configurez le site pour les protocoles http2

```sh
a2enmod http2
```

```sh
vi /etc/apache2/sites-enabled/000-default-le-ssl.conf
```

```sh
<VirtualHost *:443>

        Protocols h2 h2c http/1.1

        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/nextcloud
```

```sh
:x    // Save
```

- 4 - Maintenant, redémarrez Apache

```sh
systemctl restart apache2
```

- 5 - Testez le protocole http2 en envoyant une requête http2 au serveur Web.

```sh
curl -I --http2 -s https://nc.cfitech.be/ | grep HTTP

HTTP/2 200
```

- Ou, nous pouvons `inspecter` le navigateur lors de l'accès à l'URL Nextcloud, nous pouvons facilement voir la colonne de protocole à partir de l'onglet Réseau, et il affichera h2 comme protocole qui est http2.

- 6 - HTTP Strict Transport Security, qui indique aux navigateurs de ne pas autoriser de connexion à l'instance Nextcloud à l'aide de HTTP, empêche les attaques de type `man-in-the-middle`.

```sh
<VirtualHost *:443>
  ServerName nc.cfitech.be

<IfModule mod_headers.c>
    Header always set Strict-Transport-Security "max-age=15552000; includeSubDomains"
</IfModule>

</VirtualHost>
```

#### Étape 11. URL élégantes

- Les URL élégantes suppriment la partie `index.php` de toutes les URL Nextcloud. Les URL seront ainsi plus courtes et plus élégante

```sh
vi /var/www/nextcloud/config/config.php
```

```sh
'htaccess.RewriteBase' => '/',
```

```sh
:x
```

- Cette commande mettra à jour le fichier .htaccess pour la redirection

```sh
sudo -u www-data php --define apc.enable_cli=1 /var/www/nextcloud/occ maintenance:update:htaccess
```

- Alors, ça y est... Nous avons fait notre installation 🤗
