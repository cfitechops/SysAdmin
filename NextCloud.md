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

- Ajouter le sous-domaine de Cloudflareex: nextcloud.diarabaka.com

```sh
sudo nano /etc/hosts
```

- Ajouter une ligne `127.0.1.1 ex: venetian nextcloud.diarabaka.com`

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
SHOW DATABASES;
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
mv nextcloud nextcloud.diarabaka.com
```

- 5 - Modifier la propriété de nextcloud

```sh
sudo chown -R www-data:www-data nextcloud.diarabaka.com
```

- 6 - Déplacer nextcloud vers Apache

```sh
sudo mv nextcloud.diarabaka.com /var/www
```

- 7 - Désactiver le site Apache par défaut

```sh
sudo a2dissite 000-default.conf
```

- 8 - Configurer Apache pour Nextcloud

```sh
<VirtualHost *:80>
    DocumentRoot "/var/www/nextcloud.diarabaka.com"
    ServerName nextcloud.diarabaka.com

    <Directory "/var/www/nextcloud.diarabaka.com/">
        Options MultiViews FollowSymlinks
        AllowOverride All
        Require all granted
    </Directory>

    TransferLog /var/log/apache2/nextcloud.diarabaka.com_access.log
    ErrorLog /var/log/apache2/nextcloud.diarabaka.com_error.log
</VirtualHost>
```

- 9 - Activer le site Nextcloud et redémarrer Apache

```sh
sudo a2ensite nextcloud.diarabaka.com.conf
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

- 1 - Installation via le Web: `https://nextcloud.diarabaka.com`
- 2 - Installer les applications recommandées

## Partie 3 : Gérer les avertissements

- 1 - Modifier les autorisations de config.php

```sh
sudo chmod 660 /var/www/nextcloud.diarabaka.com/config/config.php
```

- 2 - Certains indices facultatifs manquants ont été détectés.

- Rendre occ exécutable :

```sh
sudo chmod +x /var/www/nextcloud.diarabaka.com/occ
```

- Ajoutez ensuite les indices manquants :

```sh
sudo -u www-data /var/www/nextcloud.diarabaka.com/occ db:add-missing-indices
```

- Vérifiez si l'erreur n'est plus

- 3 - Une ou plusieurs migrations de type MIME sont disponibles

```sh
sudo -u www-data /var/www/nextcloud.diarabaka.com/occ maintenance:repair --include-expensive
```

- 4 - Les avertissements suivants
  - Le serveur n'a pas d'heure de début de fenêtre de maintenance configurée.
  - La base de données est utilisée pour le verrouillage des fichiers transactionnels.
  - Aucun cache mémoire n'a été configuré.
  - Votre installation n'a pas de région téléphonique par défaut définie.
  - Vous n'avez pas encore défini ou vérifié la configuration de votre serveur de messagerie.

```sh
sudo nano /var/www/nextcloud.diarabaka.com/config/config.php
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
'default_phone_region' => 'EU',
'overwriteprotocol' => 'https',
```

- 5 - Certains en-têtes ne sont pas définis correctement sur votre instance - L' Strict-Transport-Securityen-tête HTTP n'est pas défini (doit être au moins 15552000de secondes).

```sh
sudo nano /etc/apache2/sites-available/nextcloud.diarabaka.com-le-ssl.conf
```

- Ajouter après

`Configuration SSL (effectuée par Certbot) SSLCertificateFile /etc/letsencrypt/live/nextcloud.diarabaka.com/fullchain.pem SSLCertificateKeyFile /etc/letsencrypt/live/nextcloud.diarabaka.com/privkey.pem`

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

## Partie 4 : Protection d'accès avec pare-feu

- Aucun serveur ne peut maintenir une bonne sécurité sans une politique de pare-feu active. après avoir installé et configuré nextcloud, nous devons autoriser le trafic uniquement vers des ports spécifiques, le reste des ports doit être proche du monde. si nous ajoutons plus d'applications nextcloud plus tard, nous devrons peut-être ouvrir de nouveaux ports au pare-feu plus tard.

- 1 - exécutez le code suivant pour la configuration de base du pare-feu Iptables.

```sh
nano nextcloud_iptables.sh
```

```sh
#!/bin/bash

# Flush all existing rules
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

# Allow loopback traffic
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow established and related incoming traffic
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow all outgoing traffic
iptables -A OUTPUT -j ACCEPT

# Allow incoming traffic on port 22 (SSH)
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow incoming traffic on port 80 (HTTP)
iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Allow incoming traffic on port 443 (HTTPS)
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Allow ICMP (ping)
iptables -A INPUT -p icmp -j ACCEPT

# Apply security hardening

# Protect against SYN flood attacks
iptables -A INPUT -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
iptables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP

# Protect against ping flood (limit to 1 ping per second with burst of 3)
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s --limit-burst 3 -j ACCEPT

# Protect against IP spoofing
iptables -A INPUT -s 10.0.0.0/8 -j DROP
iptables -A INPUT -s 172.16.0.0/12 -j DROP
iptables -A INPUT -s 192.168.0.0/16 -j DROP
iptables -A INPUT -s 127.0.0.0/8 -j DROP
iptables -A INPUT -s 224.0.0.0/4 -j DROP
iptables -A INPUT -s 240.0.0.0/5 -j DROP
iptables -A INPUT -s 0.0.0.0/8 -j DROP
iptables -A INPUT -s 169.254.0.0/16 -j DROP

# Log dropped packets (optional)
iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables denied: " --log-level 7

# Drop all other inbound traffic
iptables -A INPUT -j DROP

# End of script
```

- 2 - Appliquez les règles iptables via un script, suivez les

```sh
chmod +X nextcloud_iptables.sh
```

```sh
./nextcloud_iptables.sh
```

- 3 - Enregistrez les règles de manière permanente. Elles seront rechargées au redémarrage.

```sh
apt install iptables-persistent netfilter-persistent -y

systemctl enable netfilter-persistent
systemctl start netfilter-persistent
```

- 4 - Si vous mettez à jour les règles, vous devez les enregistrer afin de pouvoir les recharger lors du redémarrage.

```sh
iptables-save > /etc/iptables/rules.v4
```

- **[Remarque]** : concernant le port SSH, vous devez uniquement autoriser votre nœud ou réseau spécifique à accéder à distance à votre serveur nextcloud.
