# Nagios

- Surveiller l'état et les performances de votre infrastructure informatique est essentiel pour éviter les interruptions de service et garantir le bon fonctionnement de votre système. **Nagios** , un puissant outil de surveillance open source, vous permet de surveiller vos serveurs, vos périphériques réseau, vos services et vos applications. Il fournit des alertes et des rapports détaillés qui aident les administrateurs système à résoudre les problèmes avant qu'ils ne deviennent critiques.

- **Étape 1** : Installer les paquets de dépendances Nagios sur Ubuntu 24.04 LTS
  - Tout d’abord, mettez à jour votre liste de paquets et installez les dépendances nécessaires :

```sh
sudo apt update
sudo apt install -y build-essential libgd-dev openssl libssl-dev unzip apache2 php libapache2-mod-php php-gd
```

- **Étape 2** : Créer un utilisateur et un groupe Nagios dans Ubuntu 24.04 LTS
  - Créer un utilisateur et un groupe pour Nagios

```sh
sudo useradd nagios
sudo groupadd nagcmd
sudo usermod -a -G nagcmd nagios
sudo usermod -a -G nagcmd www-data
```

- **Étape 3** : Télécharger et compiler Nagios sur Ubuntu 24.04 LTS
  - Téléchargez la dernière version de Nagios Core et extrayez-la : Pour télécharger la dernière version, visitez [le site officiel de Nagios](https://www.nagios.org/downloads/nagios-core/thanks/)

```sh
cd /tmp
wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.5.1.tar.gz
tar xzf nagios-4.5.1.tar.gz
cd nagios-4.5.1
```

- Configurer et compiler Nagios

```sh
./configure --with-nagios-group=nagios --with-command-group=nagcmd
make all
```

- **Étape 4** : Installer Nagios sur Ubuntu 24.04 LTS
  - Installez les binaires Nagios, les scripts d'initialisation et le mode de commande :

```sh
sudo make install
sudo make install-init
sudo make install-commandmode
sudo make install-config
sudo make install-webconf
```

- **Étape 5** : Installer les plugins Nagios sur Ubuntu 24.04 LTS
  - Téléchargez et installez les plugins Nagios sur Ubuntu 24.04 LTS

```sh
cd /tmp
wget https://nagios-plugins.org/download/nagios-plugins-2.3.3.tar.gz
tar xzf nagios-plugins-2.3.3.tar.gz
cd nagios-plugins-2.3.3
./configure --with-nagios-user=nagios --with-nagios-group=nagios
make
sudo make install
```

- **Étape 6** : Configurer Apache sur Ubuntu 24.04 LTS
  - Activez les modules Apache et redémarrez le service :

```sh
sudo a2enmod rewrite
sudo a2enmod cgi
sudo systemctl restart apache2
```

- **Étape 7** : Configurer l'interface Web Nagios sur Ubuntu 24.04 LTS
  - Créez un utilisateur administrateur Nagios pour l'interface Web :

```sh
sudo htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
```

- **Étape 8** : Démarrez le service Nagios sur la ligne de commande Ubuntu 24.04 LTS
  - Démarrez et activez le service Nagios

```sh
sudo systemctl start nagios
sudo systemctl enable nagios
```

- **Étape 9** : Accéder à l'interface Web Nagios sur Ubuntu 24.04 LTS
  - Ouvrez votre navigateur Web et accédez à `http://<your-server-ip>/nagios`. Connectez-vous avec le nom d'utilisateur nagiosadmin et le mot de passe que vous avez définis précédemment.

![nagois](/assets/nagios_01.png)

- Vous pouvez utiliser la console pour la surveillance :

![nagois](/assets/nagios_02.png)
