# GLPI (Gestionnaire Libre de Parc Informatique)

- **GLPI** est un outil open-source de gestion des actifs informatiques (ITSM) qui permet de gérer les tickets, les inventaires matériels/logiciels, et bien plus encore.

- 1. Mise à jour du système
  - Avant toute installation, il est essentiel de mettre à jour les paquets

```sh
sudo -i

apt update && apt -y dist-upgrade
```

- 2. Installation et configuration de SSH
  - Pour sécuriser l’accès distant

```sh
apt -y install openssh-server
nano /etc/ssh/sshd_config
```

- Modifier la ligne suivante

```sh
PermitRootLogin yes
```

- Puis redémarrer le service

```sh
systemctl restart sshd
```

- 3. Installation d’Apache2
  - GLPI nécessite un serveur web. Nous utiliserons Apache

```sh
apt install apache2 -y
```

- 4. Installation de PHP 8.2
  - GLPI requiert PHP. Nous ajoutons le dépôt Ondřej Surý

```sh
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
```

- Installation des modules nécessaires

```sh
sudo apt install -y \
    php8.2-cli php8.2-fpm php8.2-common php8.2-mysql \
    php8.2-curl php8.2-gd php8.2-intl php8.2-mbstring \
    php8.2-xml php8.2-zip php8.2-bcmath php8.2-gmp \
    php8.2-opcache php8.2-apcu
```

- Vérification

```sh
php8.2 -v
php8.2 -m
```

- 5. Installation de MariaDB (MySQL)
  - GLPI utilise une base de données

```sh
apt -y install mariadb-server
systemctl restart mariadb
```

- Sécurisation de MariaDB

```sh
mysql_secure_installation
```

- Répondre

```sh
Switch to unix_socket authentication [Y/n] → **n**
Change the root password? [Y/n] → **n**
Remove anonymous users? [Y/n] → **y**
Disallow root login remotely? [Y/n] → **y**
Remove test database? [Y/n] → **y**
Reload privileges? [Y/n] → **y**
```

- 6. Création de la base de données GLPI

```sh
mysql -u root
```

- Exécuter dans MySQL

```sh
CREATE DATABASE glpi;
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'cfitech';
GRANT ALL PRIVILEGES ON glpi.* TO 'admin'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

- 7. Téléchargement et installation de GLPI
  - Récupération depuis GitHub

```sh
wget https://github.com/glpi-project/glpi/releases/download/10.0.18/glpi-10.0.18.tgz
tar -xvf glpi-10.0.18.tgz -C /var/www/html/
```

- Droits d’accès

```sh
chown -R www-data:www-data /var/www/html/glpi
```

- 8. Configuration d’Apache pour GLPI
  - Éditer la configuration par défaut

```sh
nano /etc/apache2/sites-available/000-default.conf
```

- Remplacer par

```sh
<VirtualHost *:80>
    DocumentRoot /var/www/html/glpi
    ServerName votredomaine.com

    <Directory /var/www/html/glpi>
        Options FollowSymlinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/glpi_error.log
    CustomLog ${APACHE_LOG_DIR}/glpi_access.log combined
</VirtualHost>
```

- Redémarrer Apache

```sh
systemctl restart apache2
```

- 9. Installation via l’interface web
  - Accéder à

```sh
http://<IP_DU_SERVEUR>/install/install.php
```

- Sélectionner la langue et suivre l’assistant.

- Entrer les informations de la base de données

```sh
Serveur : localhost
Utilisateur : admin
Mot de passe : cfitech
Base de données : glpi
```

- Valider l’installation.

- 10. Sécurisation de GLPI
  - Supprimer le script d’installation

```sh
rm -fr /var/www/html/glpi/install/install.php
```

- Modifier `php.ini` pour renforcer la sécurité

```sh
nano /etc/php/8.2/apache2/php.ini
```

- Ajouter/modifier

```sh
session.cookie_httponly = on
```

- Redémarrer Apache

```sh
systemctl restart apache2
```

- 11. Accès à GLPI
  - L’interface est disponible à l’adresse

```sh
http://<IP_DU_SERVEUR>
```

- Identifiant par défaut : `glpi`

- Mot de passe : `glpi`
