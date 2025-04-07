# GLPI (Gestionnaire Libre de Parc Informatique)

## GLPI

- GLPI est un outil open-source de gestion des actifs informatiques (IT Service Management) qui permet de gérer les tickets, les inventaires matériels/logiciels, et bien plus encore.

- Gestion des Actifs Informatiques (ITAM)

  - Inventaire matériel (PC, serveurs, imprimantes, etc.)
  - Inventaire logiciel (licences, versions installées)
  - Suivi des configurations (CMDB)

- Gestion des Tickets (Helpdesk)

  - Création et suivi des `incidents` et `demandes`
  - Attribution aux techniciens
  - Historique des résolutions

- Gestion des Projets et Tâches

  - Planification des interventions
  - Suivi des délais et priorités

- Automatisation (via plugins)

  - Intégration avec FusionInventory (découverte automatique des équipements)
  - Connexion à LDAP/Active Directory (authentification centralisée)
  - Génération de rapports

- Conformité et Sécurité
  - Gestion des licences logicielles
  - Audit des configurations
  - Suivi des vulnérabilités

## Pourquoi utiliser GLPI ?

🔹 Gratuit (contrairement à ServiceNow, BMC Remedy, etc.)
🔹 Personnalisable (plugins, thèmes, workflows)
🔹 Communauté active (mises à jour fréquentes)
🔹 Multi-utilisateurs (rôles et permissions avancés)

## Cas d'Usage

- `Helpdesk` : Un employé ouvre un ticket pour un problème de réseau → GLPI le route vers l’équipe support.
- `Inventaire` : Scan automatique des nouveaux PC avec FusionInventory.
- `Licences` : Alerte quand une licence Microsoft est sur le point d’expirer

- Avant toute installation, il est essentiel de mettre à jour les paquets

```sh
sudo -i

apt update && apt -y dist-upgrade
```

- Installation et configuration de SSH, pour sécuriser l’accès distant

```sh
apt -y install openssh-server

nano /etc/ssh/sshd_config
```

- Modification dans le fichier

```sh
PermitRootLogin yes
```

- Puis redémarrer le service

```sh
systemctl restart sshd
```

- Installation d’Apache2
  - GLPI nécessite un serveur web. Nous utiliserons Apache

```sh
apt install apache2 -y
```

- Installation de PHP 8.2
  - GLPI requiert PHP. Nous ajoutons le dépôt Ondřej Surý

```sh
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
```

- Installation des modules PHP 8.2

```sh
sudo apt install -y \
    php8.2-cli \
    php8.2-fpm \
    php8.2-common \
    php8.2-mysql \
    php8.2-curl \
    php8.2-gd \
    php8.2-intl \
    php8.2-mbstring \
    php8.2-xml \
    php8.2-zip \
    php8.2-bcmath \
    php8.2-gmp \
    php8.2-opcache \
    php8.2-apcu
```

- Vérification de PHP

```sh
php8.2 -v
php8.2 -m
```

- Installation de dépendances supplémentaires

```sh
sudo apt update && sudo apt install -y \
    libapache2-mod-php8.2 \
    hunspell \
    certbot \
    imagemagick \
    unzip \
    php8.2-opcache
```

- Vérification et configuration PHP

```sh
php -v
ls /etc/php/
```

- Création d'un fichier PHP de test

```sh
nano /var/www/html/main.php
```

- Contenu

```sh
<?php phpinfo(); ?>
```

- Puis

```sh
systemctl restart apache2
systemctl status apache2
```

- Accès via : `http://<IP_SERVER>/main.php`

- Installation de MariaDB (MySQL)
  - GLPI utilise une base de données

```sh
apt -y install mariadb-server
systemctl restart mariadb
```

- Sécurisation de MariaDB

```sh
mysql_secure_installation
```

- Réponses

```sh
Switch to unix_socket authentication [Y/n] n
Change the root password? [Y/n] n
Remove anonymous users? [Y/n] y
Disallow root login remotely? [Y/n] y
Remove test database and access to it? [Y/n] y
Reload privilege tables now? [Y/n] y
```

- Puis

```sh
systemctl restart mariadb
```

- Création de la base de données GLPI

```sh
mysql -u root
```

- Exécuter dans MySQL

```sh
show databases;
create database glpi;
create user 'admin'@localhost identified by 'cfitech';
grant all privileges on glpi.* to admin@localhost;
flush privileges;
exit
```

- Puis

```sh
systemctl restart mariadb
```

- Téléchargement et extraction de GLPI
  - Depuis : [https://glpi-project.org/downloads/](https://glpi-project.org/downloads/)

```sh
wget https://github.com/glpi-project/glpi/releases/download/10.0.18/glpi-10.0.18.tgz
tar -xvf glpi-10.0.18.tgz -C /var/www/html/
ls /var/www/html/
```

- Configuration d'Apache pour GLPI

```sh
nano /etc/apache2/sites-available/000-default.conf
```

- Contenu

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

- Puis droits d’accès

```sh
chown -R www-data:www-data /var/www/html/glpi
ls -l /var/www/html
```

- Installation et activation de SELinux

```sh
sudo apt install selinux-basics selinux-policy-default auditd

sudo selinux-activate

nano /etc/selinux/config
```

- Modification

```sh
SELINUX=Enforcing
```

- Installation de modules PHP supplémentaires

```sh
sudo apt install php8.2-ldap php8.2-imap php8.2-xmlrpc
systemctl restart apache2
```

- Installation de GLPI via l'interface web
  - Accès à : `http://<IP_SERVER>/install/install.php`
  - Sélectionner la langue et suivre l’assistant
  - Entrer les informations de la base de données
  - Valider l’installation

```sh
Serveur : localhost
Utilisateur : admin
Mot de passe : cfitech
Base de données : glpi
```

- Sécurisation de GLPI
  - Supprimer le script d’installation

```sh
rm -fr /var/www/html/glpi/install/install.php
```

- Ouvrir le fichier SafeDocumentRoot.php

```sh
nano /var/www/html/glpi/src/System/Requirement/SafeDocumentRoot.php
```

- Recherchez la structure conditionnelle `else` qui valide le `DocumentRoot`.
- Modifier le code comme suit

```sh
else {
    $this->validated = false;
    return; // Ajout de cette ligne pour éviter les erreurs inutiles
}
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

- Accès à GLPI
  - L’interface est disponible à l’adresse `http://<IP_SERVER>`
  - Identifiant par défaut : `glpi`
  - Mot de passe : `glpi`

![GLPI](/assets/glpi.png)
