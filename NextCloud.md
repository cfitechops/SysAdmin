# Installation du serveur Ubuntu - Nextcloud

## Partie 1 : Configuration de Cloudflare

- 1 - Assurez-vous que votre domaine utilise Cloudflare DNS

![Nextcloud](/assets/cloudflare.png)

- 2 - Cloudflare Zero Trust

- 3 - Accédez à Réseau > Tunnels .

- 4 - Créez le tunnel et sélectionnez l’architecture Debian 64 bits.

- 5 - Copiez le connecteur Cloudflared et installez-le sur le serveur Ubuntu 24.04

- 6 - Configurer le nom d'hôte public

![Nextcloud](/assets/cloudflare-2.png)

## Partie 2 : Installation de Nextcloud sur Ubuntu Server 24.04

- **Étape 1** : Configuration initiale
- 1 - Installer les packages nécessaires :

```sh
sudo apt install -y eza redis-server build-essential unzip libmagickwand-dev librsvg2-dev libmagickcore-6.q16-7-extra
```

- 2 - Remplacer .bashrc:

```sh
rm ~/.bashrc
wget https://raw.githubusercontent.com/drewgrif/jag_dots/main/.bashrc_server
mv ~/.bashrc_server ~/.bashrc
bash
```

- 3 - Mise à jour et mise à niveau :

```sh
sudo apt update && sudo apt upgrade -y && sudo apt clean
```

- 4 - Mise à jour du nom d'hôte

```sh
sudo nano /etc/hostname
```

- Ajouter le sous-domaine de Cloudflareex: my.cfitech.cloud

```sh
sudo nano /etc/hosts
```

- Ajouter une ligne `127.0.1.1 ex: venetian my.cfitech.cloud`

- 5 - Redémarrer le serveur

```sh
sudo reboot
```

- Reconnectez-vous

#### Étape 2 : Téléchargement et installation de Nextcloud

- Télécharger Nextcloud :

```sh
wget https://download.nextcloud.com/server/releases/latest.zip
```

- Installer MariaDB :

```sh
sudo apt install -y mariadb-server
sudo mysql_secure_installation
```

- 2a. mysql_secure_installation

```sh
Enter current password for root (enter for none): Enter
Switch to unix_socket_authentication [Y/n] n
Change root password [Y/n] Y
Set password
Remove anonymous users? Y
Disallow root login remotely? Y
Remove test database and access to it? Y
Reload privilidge tables now? Y
```

- Créer une base de données Nextcloud

```sh
sudo mariadb
```

- À l'intérieur du shell MariaDB :

```sh
CREATE DATABASE nextcloud;
GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'localhost' IDENTIFIED BY 'mypassword';
FLUSH PRIVILEGES;
```

- Sortir avec `CTRL+D`.

#### Étape 3 : Configurer le serveur Web Apache

- 1 - Installer les packages PHP requis :

```sh
sudo apt install php php-apcu php-bcmath php-cli php-common php-curl php-gd php-gmp php-imagick php-intl php-mbstring php-mysql php-zip php-xml php-redis
```

- 2 - Activer les modules Apache

```sh
sudo a2enmod dir env headers mime rewrite ssl
```

```sh
sudo phpenmod bcmath gmp imagick intl redis
```

- 3 - Décompressez Nextcloud :

```sh
unzip latest.zip
```

- 4 - Renommer nextcloud en sous-domaine

```sh
mv nextcloud my.cfitech.cloud
```

- 5 - Modifier la propriété de nextcloud

```sh
sudo chown -R www-data:www-data my.cfitech.cloud
```

- 6 - Déplacer nextcloud vers Apache

```sh
sudo mv my.cfitech.cloud /var/www
```

- 7 - Désactiver le site Apache par défaut

```sh
sudo a2dissite 000-default.conf
```

- 8 - Configurer Apache pour Nextcloud

```sh
<VirtualHost *:80>
    DocumentRoot "/var/www/my.cfitech.cloud"
    ServerName my.cfitech.cloud

    <Directory "/var/www/my.cfitech.cloud/">
        Options MultiViews FollowSymlinks
        AllowOverride All
        Require all granted
    </Directory>

    TransferLog /var/log/apache2/my.cfitech.cloud_access.log
    ErrorLog /var/log/apache2/my.cfitech.cloud_error.log
</VirtualHost>
```

- 9 - Activer le site Nextcloud et redémarrer Apache

```sh
sudo a2ensite my.cfitech.cloud.conf
sudo systemctl restart apache2
```

- 10 - Installation de SSL

```sh
sudo snap install core; sudo snap refresh core
```

- 11 - Installer Certbot

```sh
sudo snap install --classic certbot
```

```sh
sudo ln -s /snap/bin/certbot /usr/bin/certbot
```

- 12 - Tenter d'obtenir un certificat (le DNS doit déjà avoir été propagé)

```sh
sudo certbot --apache
```

#### Étape 4 : Ajuster les paramètres PHP

- 1 - Modifier la configuration PHP

```sh
sudo nano /etc/php/8.3/apache2/php.ini
```

- Certains d'entre eux devront être modifiés, d'autres devront être décommentés et modifiés.

```sh
memory_limit = 512M

upload_max_filesize = 2 Go

max_execution_time = 360

post_max_size = 2G

date.timezone = Europe/Belgium

opcache.enable = 1

opcache.interned_strings_buffer = 32

opcache.max_accelerated_files = 10000

opcache.memory_consumption = 128

opcache.save_comments = 1

opcache.revalidate_freq = 1
```

- 2 - Activer le module ACPU

```sh
sudo nano /etc/php/8.3/mods-available/apcu.ini
```

- Ajouter au fichier `:apc.enable_cli=1`

- 3 - Redémarrer Apache

```sh
sudo systemctl restart apache2
```

#### Étape 5 : Nextcloud via un navigateur Web

- 1 - Installation via le Web: `https://my.cfitech.cloud`
- 2 - Installer les applications recommandées

## Partie 3 : Gérer les avertissements

- 1 - Modifier les autorisations de config.php

```sh
sudo chmod 660 /var/www/my.cfitech.cloud/config/config.php
```

- 2 - Certains indices facultatifs manquants ont été détectés.

- Rendre occ exécutable :

```sh
sudo chmod +x /var/www/my.cfitech.cloud/occ
```

- Ajoutez ensuite les indices manquants :

```sh
sudo -u www-data /var/www/my.cfitech.cloud/occ db:add-missing-indices
```

- Vérifiez si l'erreur n'est plus

- 3 - Une ou plusieurs migrations de type MIME sont disponibles

```sh
sudo -u www-data /var/www/my.cfitech.cloud/occ maintenance:repair --include-expensive
```

- 4 - Les avertissements suivants
  - Le serveur n'a pas d'heure de début de fenêtre de maintenance configurée.
  - La base de données est utilisée pour le verrouillage des fichiers transactionnels.
  - Aucun cache mémoire n'a été configuré.
  - Votre installation n'a pas de région téléphonique par défaut définie.
  - Vous n'avez pas encore défini ou vérifié la configuration de votre serveur de messagerie.

```sh
sudo nano /var/www/my.cfitech.cloud/config/config.php
```

- Retirer: `maintenance => false,`

- Ajouter:

```sh
'mail_from_address' => 'nextcloud',
'mail_smtpmode' => 'smtp',
'mail_sendmailmode' => 'smtp',
'mail_domain' => 'gmail.com',
'mail_smtphost' => 'smtp.gmail.com',
'mail_smtpport' => '587',
'mail_smtpauth' => 1,
'mail_smtpname' => 'nextcloud@gmail.com',
'mail_smtppassword' => 'app-specific-pw',
'maintenance_window_start' => 1,
'memcache.local' => '\\OC\\Memcache\\APCu',
'memcache.distributed' => '\\OC\\Memcache\\Redis',
'memcache.locking' => '\\OC\\Memcache\\Redis',
'redis' =>
array (
'host' => 'localhost',
'port' => 6379,
),
'default_phone_region' => 'US',
'overwriteprotocol' => 'https',
```

- 5 - Certains en-têtes ne sont pas définis correctement sur votre instance - L' Strict-Transport-Securityen-tête HTTP n'est pas défini (doit être au moins 15552000de secondes).

```sh
sudo nano /etc/apache2/sites-available/my.cfitech.cloud-le-ssl.conf
```

- Ajouter après

`Configuration SSL (effectuée par Certbot) SSLCertificateFile /etc/letsencrypt/live/my.cfitech.cloud/fullchain.pem SSLCertificateKeyFile /etc/letsencrypt/live/my.cfitech.cloud/privkey.pem`

```sh
Paste
```

- En-tête HSTS

```sh
Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"
```

```sh
sudo systemctl restart apache2
```

```sh
Source : https://www.learnlinux.tv/complete-walkthrough-for-installing-nextcloud-on-ubuntu-24-04/
```
