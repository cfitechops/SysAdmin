# Installer NextCloud sur Ubuntu 22.04 LTS

- **NextCloud** est un système d'hébergement de fichiers qui permet de stocker du contenu (documents, images, vidéos, etc.) et de le partager.

- Au lieu de dépendre de prestataires de services externes pour nos documents personnels et professionnels, Nextcloud nous donne la liberté de les stocker sur nos serveurs ou dans des centres de données de confiance.

- Il s'agit d'un système centralisé de gestion de documents et de fichiers autogéré. Open Source, il nous permet d'utiliser et d'adapter l'application selon nos besoins. Nous en avons le contrôle total, ce qui nous permet de mettre en place nos propres mesures de sécurité pour sécuriser nos contenus.

- L'installation de Nextcloud est simple et directe, il existe de nombreuses étapes pour améliorer les fonctionnalités de Nextcloud, ci-dessous, nous avons fourni les étapes très basiques pour installer rapidement Nextcloud sur Ubuntu 22.04 LTS.

#### Table des matières

- Étape 1 : Installer les packages PHP et MySQL
- Étape 2 : Configurer le serveur MySQL
- Étape 3 : Téléchargez et installez Nextcloud
- Étape 4 : Finaliser la configuration à partir du navigateur

#### Étape 1 : Installer les packages PHP et MySQL

- 1. Mettre à jour et mettre à niveau les packages Ubuntu

```sh
apt update && apt upgrade
```

- 2. installer Apache et MySQL Server

```sh
apt install apache2 mariadb-server
```

- 3. Installez PHP et les autres dépendances et redémarrez Apache

```sh
apt install libapache2-mod-php php-bz2 php-gd php-mysql php-curl \
php-mbstring php-imagick php-zip php-ctype php-curl php-dom \
php-json php-posix php-bcmath php-xml php-intl php-gmp zip unzip wget
```

- 4. Activez les modules Apache requis et redémarrez Apache

```sh
a2enmod rewrite dir mime env headers
systemctl restart apache2
```

#### Étape 2 : Configurer le serveur MySQL

- 1. Connectez-vous à l'invite MySQL, tapez simplement

```sh
mysql
```

- 2. Créez une base de données MySQL et un utilisateur pour Nextcloud et fournissez des autorisations.

```sh
CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY 'passw@rd';
CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'localhost';
FLUSH PRIVILEGES;
quit;
```

#### Étape 3 : Téléchargez et installez Nextcloud

Téléchargez maintenant la dernière archive Nextcloud. Accédez à la [page de téléchargement Nextcloud.](https://nextcloud.com/install/).

- 1. Téléchargez et décompressez le dossier racine Web (/var/www/html)

```sh
cd /var/www/html
rm index.html
wget https://download.nextcloud.com/server/releases/latest.zip
unzip latest.zip
```

- 2. Déplacez tout le contenu de nextcloud vers le dossier racine Web (/var/www/html)

```sh
cd /var/www/html/nextcloud
mv * .* ../
```

- 3. Supprimez le répertoire nextcloud vide

```sh
rmdir /var/www/html/nextcloud
```

- 4. Modifiez la propriété du répertoire de contenu Nextcloud en l'attribuant à l'utilisateur HTTP.

```sh
chown -R www-data:www-data /var/www/html
```

#### Étape 4 : Finaliser la configuration à partir du navigateur

- Accédez maintenant à votre navigateur et saisissez `http:// [adresse IP ou nom de domaine complet]` du serveur. La page d'installation de Nextcloud ci-dessous s'affiche. Vous devez y renseigner :

- 1. le nom d'utilisateur et le mot de passe de l'administrateur Nextcloud
- 2. les identifiants de la base de données (nom, utilisateur et mot de passe de la base de données).

- Après avoir fourni toutes les informations, cliquez sur le bouton Installer. Il installera Nextcloud dans une minute et fournira la page d'installation de l'application recommandée.
