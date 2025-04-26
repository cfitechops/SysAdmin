# MariaDB

- MariaDB est un système de base de données open source populaire, largement utilisé pour sa fiabilité et ses performances. Il s'agit d'un fork de MySQL, conçu pour rester entièrement open source. Ubuntu 24.04, avec sa stabilité et sa flexibilité, est une excellente plateforme pour exécuter MariaDB.

#### Installer MariaDB sur Ubuntu 24.04 LTS

- Mettre à jour Ubuntu

```sh
sudo apt update
```

- Installer MariaDB

```sh
sudo apt install mariadb-server
```

- Vérifier la version de MariaDB

```sh
mariadb --version
```

- Activez le service système MariaDB pour qu'il démarre au démarrage.

```sh
sudo systemctl enable mariadb
```

- Démarrer MariaDB

```sh
sudo systemctl start mariadb
```

- Voir l'état de MariaDB

```sh
sudo systemctl status mariadb
```

- Sécuriser le serveur MariaDB sur Ubuntu 24.04 LTS
  - Exécutez le script de sécurité MariaDB

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

- Accéder à MariaDB sur Ubuntu 24.04 LTS
  - Connectez-vous au serveur de base de données MariaDB :

```sh
sudo mariadb -u root -p
```

- Pour créer une nouvelle base de données et un nouvel utilisateur, utilisez les commandes suivantes dans le shell MariaDB :
  - Créer une nouvelle base de données :

```sh
CREATE DATABASE mydatabase;
```

- Créez un nouvel utilisateur avec un mot de passe fort :

```sh
CREATE USER 'myuser'@'localhost' IDENTIFIED BY 'mypassword';
```

- Accorder des privilèges au nouvel utilisateur sur la nouvelle base de données :

```sh
GRANT ALL PRIVILEGES ON mydatabase.* TO 'myuser'@'localhost';
```

- Utilisez la commande ci-dessous pour appliquer les modifications :

```sh
FLUSH PRIVILEGES;
```

- Affichez toutes les bases de données sur le serveur en utilisant la commande ci-dessous :

```sh
SHOW DATABASES;
```

- Pour quitter le shell MariaDB, tapez simplement :

```sh
exit
```
