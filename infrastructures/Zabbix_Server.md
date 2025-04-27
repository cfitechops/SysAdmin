# Installer et configurer le serveur Zabbix sur Ubuntu 24.04

- Zabbix est une solution de surveillance largement utilisée dans les environnements Linux, Windows, Unix et les appliances réseau. Elle permet d'extraire de nombreux paramètres réseau tels que la disponibilité, les performances générales et les mesures de sécurité. Zabbix est si mature et stable qu'il est utilisé par de grandes organisations comptant des milliers d'équipements réseau, de serveurs et d'applications déployées. Le logiciel Zabbix est publié sous licence publique générale GNU, ce qui le rend libre d'utilisation, de modification et de distribution.

## Voici quelques avantages du serveur Zabbix comme solution de surveillance :

- **Zabbix est hautement personnalisable** : vous pouvez facilement étendre les fonctionnalités de Zabbix en écrivant des scripts et des intégrations personnalisés.
- **C'est une solution open source** : Zabbix est une option intéressante si le coût est un facteur important pour votre organisation. Vous pouvez la déployer et l'adapter gratuitement à vos besoins.
- **Zabbix est hautement évolutif** : son architecture est conçue pour les installations à grande échelle avec des milliers d'appareils à surveiller. Le déploiement de serveurs proxy renforce son évolutivité.
- **Développement actif et communauté** : Zabbix bénéficie d'une vaste communauté dédiée à en faire une solution de surveillance performante.
- **Prise en charge du clustering** : vous pouvez déployer Zabbix dans une configuration à haute disponibilité via le clustering pour garantir l'absence totale d'interruption de service.
- **Notifications et alertes** : Zabbix dispose d'un système d'alertes permettant de définir des déclencheurs et des actions personnalisés. Les notifications peuvent être envoyées par SMS, e-mail ou via des intégrations tierces.
- Parmi de nombreuses [autres fonctionnalités](https://www.zabbix.com/features)

#### Installer le serveur Zabbix

- Nous allons configurer les dépendances suivantes qui nous permettent d'exécuter Zabbix Server sur Ubuntu 24.04.

  - Serveur web Apache
  - PHP et extensions requises
  - Serveur de base de données MariaDB

#### 1 - Assurez-vous que le système est mis à jour

- Connectez-vous à votre système Ubuntu et assurez-vous que tous les packages sont mis à jour.

```sh
sudo apt update && sudo apt -y upgrade
```

- Redémarrez si des mises à jour du noyau ont été appliquées au système.

```sh
[ -f /var/run/reboot-required ] && sudo reboot -f
```

#### 2 - Installer PHP, Apache et MariaDB

- Installez PHP et tous les modules PHP requis pour exécuter le serveur de surveillance Zabbix sur Ubuntu.

```sh
sudo apt install php php-{snmp,cgi,mbstring,common,net-socket,gd,xml-util,mysql,bcmath,imap}
```

- Installez le serveur Web Apache qui servira les pages Web Zabbix.

```sh
sudo apt install apache2 libapache2-mod-php
```

- Notre base de données préférée dans cet article est MariaDB. Installons-la.

```sh
sudo apt install mariadb-server
```

- Validez l'installation en vérifiant les versions logicielles installées.

```sh
php --version
mariadb -V
apache2 -version
```

#### 3 - Ajouter le référentiel Zabbix APT

- Zabbix fournit [un dépôt pour](https://www.zabbix.com/download) les systèmes Linux basés sur Debian et Red Hat. Ubuntu étant un système Linux basé sur Debian, nous téléchargeons le fichier de paquet .**deb**

```sh
sudo apt install wget -y
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-2+ubuntu24.04_all.deb
```

- Installer le fichier de référentiel téléchargé :

```sh
sudo dpkg -i zabbix-release_7.0-2+ubuntu24.04_all.deb
```

#### 4 - Installer et configurer le serveur Zabbix

- Mettre à jour la liste des packages du référentiel.

```sh
sudo apt update
```

- Nous avons configuré les dépôts et sommes prêts à installer les packages serveur Zabbix. Exécutez les commandes ci-dessous pour cela.

```sh
sudo apt install vim zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent
```

- Activez PHP CGI en exécutant les commandes suivantes dans votre terminal.

```sh
sudo  a2enconf php8.*-cgi
```

- Définissez le fuseau horaire correct dans votre fichier de configuration PHP.

```sh
sudo vim /etc/php/*/apache2/php.ini
```

```sh
; https://php.net/date.timezone
date.timezone = "Europe/Brussels"
```

- Rechargez Apache pour que les modifications soient appliquées.

```sh
sudo systemctl restart apache2
```

- Confirmez l'état de votre service Web.

```sh
sudo systemctl status apache2
```

- Connectez-vous au shell MariaDB en tant qu'utilisateur root .

```sh
sudo mysql -u root
```

- Créer une base de données et un utilisateur pour Zabbix :

```sh
CREATE DATABASE zabbix character set utf8 collate utf8_bin;
GRANT ALL PRIVILEGES ON zabbix.* TO zabbix@'localhost' IDENTIFIED BY 'ZabbixDBPassw0rd';
FLUSH PRIVILEGES;
QUIT
```

- Importez ensuite les données dans la base de données créée.

```sh
sudo zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql -uzabbix -p'ZabbixDBPassw0rd' zabbix
```

- Modifiez la configuration de votre serveur Zabbix et définissez les informations d'identification de la base de données :

```sh
sudo vim /etc/zabbix/zabbix_server.conf
```

```sh
DBName=zabbix
DBUser=zabbix
DBPassword=ZabbixDBPassw0rd
```

- Redémarrez les services du serveur Zabbix à l'aide de la commande systemctl.

```sh
sudo systemctl restart zabbix-server zabbix-agent
```

- N'oubliez pas d'activer le démarrage automatique des services au démarrage du système.

```sh
sudo systemctl enable apache2 zabbix-server zabbix-agent
```

- L'état des services peut être vérifié avec les commandes ci-dessous.

```sh
sudo systemctl status zabbix-server zabbix-agent
```

#### 5 - Configurer le serveur Zabbix à partir de l'interface Web

- Ouvrez votre navigateur et accédez à l'interface Web Zabbix en utilisant l'URL `http://SeverIP/zabbix/` ou `http://hostname/zabbix/`

![Zabbix](/assets/Zabbix_01.png)

- Cliquez sur `Étape suivante` et confirmez que toutes les dépendances sont respectées. Le message `OK` devrait s'afficher.

![Zabbix](/assets/Zabbix_02.png)

- Définissez les détails de votre base de données comme configuré précédemment.

![Zabbix](/assets/Zabbix_03.png)

- Donnez un nom à votre serveur Zabbix (par exemple, le nom d'hôte). Choisissez également le thème par défaut et définissez correctement le fuseau horaire.

![Zabbix](/assets/Zabbix_04.png)

- Confirmez que toutes les configurations sont correctement définies, puis finalisez le processus.

![Zabbix](/assets/Zabbix_05.png)

- Un message de félicitations s'affiche si tout s'est déroulé comme prévu. Terminez l'installation pour vous connecter.

![Zabbix](/assets/Zabbix_06.png)

- Utilisez les informations d’identification par défaut suivantes pour accéder au tableau de bord d’administration de Zabbix.

```sh
Username: "Admin"
Password: "zabbix"
```

- Voici une capture d’écran de ce à quoi devrait ressembler le tableau de bord.

![Zabbix](/assets/Zabbix_07.png)

#### 6 - Définissez un mot de passe utilisateur administrateur fort.

- Accédez à ` Utilisateurs  >  Admin  >  Mot de passe  >  Modifier le mot de passe` comme ci-dessous.

![Zabbix](/assets/Zabbix_08.png)

- Définissez un mot de passe fort pour l'utilisateur administrateur afin de mieux sécuriser votre installation Zabbix contre les attaques.

#### 7 - Ajout d'agents de surveillance au serveur Zabbix

- Pour ajouter un nouvel hôte cible à surveiller par Zabbix, accédez à `Configuration  >  Hôtes` , vous devriez voir l'état du serveur Zabbix local activé comme ci-dessous.

![Zabbix](/assets/Zabbix_09.png)

- Les graphiques et tableaux de bord des hôtes sont accessibles via Surveillance > Hôtes . Vous pouvez ajouter d'autres hôtes en leur attribuant un nom et une adresse IP. N'oubliez pas de configurer l'agent Zabbix sur le terminal.

- **Conclusion**

  - Zabbix est une solution de surveillance performante et évolutive, adaptée aux petites comme aux grandes entreprises. Si vous avez besoin d'une configuration hautement disponible, Zabbix propose une [configuration en cluster](https://www.zabbix.com/documentation/current/en/manual/concepts/server/ha) . Cette installation sur un seul serveur convient aux petites infrastructures avec moins d'appareils répartis sur un même DC.
