# LAMP Stack

- LAMP signifie `Linux, Apache, MySQL/MariaDB et PHP`. Cette combinaison de logiciels (LAMP) est largement utilisée pour héberger des sites web et des applications web dynamiques. Nous allons passer en revue chaque composant de LAMP étape par étape pour garantir une installation réussie.

- **Étape 1** : Installer le serveur Web Apache sur Ubuntu
  - Tout d’abord, mettez à jour le cache du gestionnaire de packages pour vous assurer que votre index de packages est à jour.

```sh
sudo apt update
```

- Ensuite, installez le serveur Web Apache à l’aide du gestionnaire de packages APT.

```sh
sudo apt install apache2 -y
```

- Vérifiez qu'Apache est en cours d'exécution en vérifiant son état.

```sh
sudo systemctl status apache2
```

- Confirmez qu'Apache sert la page Web par défaut en visitant `IP address` dans votre navigateur.

- **Étape 2**: Installer le serveur de base de données MariaDB sur Ubuntu
  - Ajoutez la clé de signature et le référentiel MariaDB.

```sh
sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
```

```sh
sudo add-apt-repository 'deb [arch=amd64] http://mariadb.mirror.globo.tech/repo/10.11/ubuntu jammy main'
```

- Mettez à jour l’index du package pour inclure le nouveau référentiel.

```sh
sudo apt update
```

- Installez les packages serveur et client MariaDB.

```sh
sudo apt install mariadb-server mariadb-client -y
```

- Vérifiez la version de MariaDB installée.

```sh
mariadb --version
```

- **Étape 3** : Sécuriser le serveur de base de données MariaDB sur Ubuntu
  - Sécurisez votre installation MariaDB en exécutant le script de sécurité.

```sh
sudo mysql_secure_installation
```

```sh
Enter current password for root (enter for none): Enter
Switch to unix_socket authentication [Y/n] y
Change the root password? [Y/n] y
Remove anonymous users? [Y/n] y
Disallow root login remotely? [Y/n] y
Remove test database and access to it? [Y/n] y
Reload privilege tables now? [Y/n] y
```

- **Étape 4** : Installer PHP sur Ubuntu
  - Pour obtenir la dernière version de PHP, ajoutez le PPA Ondrej Sury.

```sh
sudo add-apt-repository ppa:ondrej/php
```

- Mettez à jour l’index du package pour inclure le nouveau référentiel.

```sh
sudo apt update
```

- Installez PHP 8.2.

```sh
sudo apt install php8.2 -y
```

- Installer des extensions PHP supplémentaires.

```sh
sudo apt install php8.2-{mbstring,mysql,zip} -y
```

- Vérifiez l'installation de PHP.

```sh
php --version
```

- **Étape 5** : Tester l'installation de PHP sur Ubuntu
  - Créez un fichier info.php dans la racine Web pour tester PHP.

```sh
sudo nano /var/www/html/info.php
```

- Ajoutez le contenu suivant.

```sh
<?php
phpinfo();
?>
```

- Enregistrez et quittez le fichier.

  - Visitez `http://Adresse IP publique/info.php` dans votre navigateur pour voir la page de configuration PHP.

- **Étape 6** : Configurer l'hôte virtuel Apache (facultatif)
  - Créez un répertoire pour votre domaine.

```sh
sudo mkdir -p /var/www/domain.com
```

- Ensuite, attribuez la propriété du répertoire suivant.

```sh
sudo chown -R $USER:$USER /var/www/domain.com
```

- L'environnement `$USER` spécifie l'utilisateur actuellement connecté. Cela implique que le répertoire du site web appartiendra à l'utilisateur connecté et non à root.

- Ensuite, attribuez des autorisations de répertoire.

```sh
sudo chmod -R 755 /var/www/domain.com
```

- Créez un exemple de fichier HTML dans le répertoire de votre domaine

```sh
sudo nano /var/www/domain.com/index.html
```

- Ajoutez le contenu suivant.

```sh
<!DOCTYPE html>
<html lang="en">
<head>
    <title>LAMP STACK</title>
</head>
<body>
    <h1>Si tu en as vraiment la volonté, tu peux y arriver</h1>
</body>
</html>
```

- Enregistrez et quittez le fichier.

- Créez un fichier de configuration d’hôte virtuel pour votre domaine.

```sh
sudo nano /etc/apache2/sites-available/domain.com.conf
```

- Ajoutez la configuration suivante.

```sh
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName domain.com
    ServerAlias www.domain.com
    DocumentRoot /var/www/domain.com
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

- Enregistrez et quittez le fichier.

- Activer le nouvel hôte virtuel.

```sh
sudo a2ensite domain.com.conf
```

- désactiver le site par défaut.

```sh
sudo a2dissite 000-default.conf
```

- Vérifiez la configuration d'Apache pour les erreurs de syntaxe.

```sh
sudo apache2ctl configtest
```

- Redémarrez Apache pour appliquer les modifications.

```sh
sudo systemctl restart apache2
```

- Visitez `IP address Public` votre navigateur pour confirmer que l'hôte virtuel fonctionne.
