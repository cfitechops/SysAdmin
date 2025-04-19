# Installer NextCloud sur Ubuntu 22.04 LTS – Guide complet

- [Nextcloud](https://nextcloud.com/) est un système d'hébergement de fichiers qui nous permet de stocker notre contenu comme des documents, des images, des vidéos, etc., et de le partager avec d'autres.

- Au lieu de dépendre de prestataires de services externes pour nos documents personnels et professionnels, Nextcloud nous donne la liberté de les stocker sur nos serveurs ou dans des centres de données de confiance. Il s'agit d'un système centralisé de gestion de documents et de fichiers autogéré.

- Cette configuration détaillée vous permettra d'optimiser les performances de NextCloud et d'appliquer toutes les mesures de sécurité nécessaires pour sécuriser le serveur.

- Vous trouverez ci-dessous des instructions détaillées pour installer Nextcloud sur Ubuntu 22.04 LTS. Pour garantir des performances et une sécurité optimales, nous avons ajouté les étapes nécessaires à l'ajout de fonctionnalités supplémentaires au système. Chaque étape est fortement recommandée pour configurer un environnement Nextcloud de production

#### Table des matières

- Étape 1 : installer les packages requis
- Étape 2. Configurer le serveur MySQL
- Étape 3. Téléchargez, extrayez et appliquez les autorisations.
- Étape 4. Installer NextCloud depuis la ligne de commande
- Étape 5. Installer et configurer PHP-FPM avec Apache
- Étape 6. Créer une page info.php pour vérifier les fonctionnalités PHP
- Étape 7. Activer Opcache en PHP
- Étape 8. Activer APCu en PHP
- Étape 9. Installer et configurer Redis
- Étape 10. Installer SSL et activer HTTP2
- Étape 11. URL élégantes

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

- Nous allons installer Nextcloud sur Ubuntu 22.04 en ligne de commande. Cela nous fera gagner du temps, car nous fournirons toutes les informations d'identification de base de données et d'administrateur nécessaires à l'installation. L'installation de Nextcloud se fera en mode silencieux, sans configuration web. Pour une installation détaillée de Nextcloud en ligne de commande, consultez cette page .
