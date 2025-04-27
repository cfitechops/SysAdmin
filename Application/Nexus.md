# Nexus Repository Manager

- Dans l'environnement de développement logiciel actuel, une gestion efficace des dépendances et un stockage efficace des artefacts sont essentiels pour des applications de haute qualité. Nexus Repository, un outil open source de Sonatype, offre une solution puissante pour gérer les binaires, les bibliothèques et autres artefacts tout au long du cycle de développement. Il simplifie la collaboration en permettant aux équipes de partager et de déployer efficacement les artefacts.

- Cet repository propose un guide étape par étape pour installer le dépôt Nexus sur Ubuntu 24.04 LTS. Que vous soyez un développeur expérimenté ou débutant, ce guide vous aidera à configurer votre instance Nexus pour optimiser votre flux de développement. C'est parti !

#### Installer OpenJDK 17 sur Ubuntu 24.04 LTS

- Installer OpenJDK 17

```sh
sudo apt update
sudo apt install openjdk-17-jdk -y
```

- Vérifier l'installation :

```sh
java -version
```

#### Téléchargez et installez Nexus Repository Manager sur Ubuntu 24.04 LTS

- Accédez [à la page de téléchargement du référentiel Nexus](https://help.sonatype.com/en/download.html) et copiez le lien vers la dernière version. Utilisez ensuite ce lien getpour la télécharger.

```sh
cd /opt
sudo wget sudo wget https://download.sonatype.com/nexus/3/nexus-3.79.1-04-linux-x86_64.tar.gz
```

- Une fois le téléchargement terminé, extrayez l'archive tar

```sh
sudo tar -xvzf nexus-3.79.1-04-linux-x86_64.tar.gz
```

- Renommez le dossier de configuration Nexus extrait en Nexus :

```sh
sudo mv /opt/nexus-3.79.1-04 /opt/nexus
```

- Par mesure de sécurité, n'exécutez pas le service Nexus à l'aide de l'utilisateur root. Créons donc un nouvel utilisateur nommé `Nexus` pour exécuter le service Nexus :

```sh
sudo adduser nexus
```

- Pour ne définir aucun mot de passe pour l'utilisateur Nexus, ouvrez le fichier `visudo` dans Ubuntu :

```sh
sudo visudo
```

- Ajoutez-y la ligne ci-dessous, enregistrez et quittez :

```sh
nexus ALL=(ALL) NOPASSWD: ALL
```

- Accordez l'autorisation d'accéder aux fichiers et au répertoire Nexus à l'utilisateur `Nexus` :

```sh
sudo chown -R nexus:nexus /opt/nexus
sudo chown -R nexus:nexus /opt/sonatype-work
```

- Pour exécuter Nexus en tant que service au démarrage, ouvrez le fichier `/opt/nexus/bin/nexus.rc` , supprimez-le du commentaire et ajoutez l'utilisateur Nexus comme indiqué ci-dessous :

```sh
sudo nano /opt/nexus/bin/nexus.rc
```

- décommentez et ajoutez :

```sh
run_as_user="nexus"
```

- Ouvrir le `/opt/nexus/bin/nexus.vmoptions` fichier:

```sh
sudo nano /opt/nexus/bin/nexus.vmoptions
```

- Pour augmenter la taille du tas JVM Nexus, vous pouvez modifier la taille comme indiqué ci-dessous :

```sh
-XX:MaxDirectMemorySize=2703m
-Djava.net.preferIPv4Stack=true
```

#### Exécutez Nexus en tant que service à l'aide de Systemd

- Pour exécuter Nexus en tant que service à l'aide de Systemd :

```sh
sudo nano /etc/systemd/system/nexus.service
```

- insérez le contenu ci-dessous

```sh
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
```

- Démarrer Nexus :

```sh
sudo systemctl start nexus
```

- Activer le service Nexus au démarrage du système :

```sh
sudo systemctl enable nexus
```

- vérifier l'état du service Nexus :

```sh
sudo systemctl status nexus
```

#### Accéder au référentiel Nexus sur l'interface Web

- Pour accéder à l'interface Web du référentiel Nexus, ouvrez votre navigateur.

- si vous exécutez le pare-feu UFW sur Ubuntu, ouvrez le port du pare-feu 8081 à l'aide de la commande ci-dessous :

```sh
ufw allow 8081/tcp
```

- Utilisez la commande ci-dessous pour ouvrir l'interface Web du référentiel Nexus :

```sh
http://server_IP:8081
```

- vous verrez ci-dessous la page Nexus par défaut :

![nexus ](/assets/nexus_01.png)

- Pour vous connecter à Nexus, cliquez sur **Se connecter** , le nom d'utilisateur par défaut est **admin**

- Pour trouver le mot de passe par défaut, exécutez la commande ci-dessous :

```sh
sudo nano /opt/sonatype-work/nexus3/admin.password
```

- copiez le mot de passe Nexus par défaut et connectez-vous, vous pouvez réinitialiser le mot de passe une fois connecté à Nexus :

![nexus ](/assets/nexus_02.png)

- L'assistant de configuration Nexus ci-dessous s'affichera :

![nexus ](/assets/nexus_03.png)

- Modifier le mot de passe administrateur Nexus par défaut :

![nexus ](/assets/nexus_04.png)

- configurer l'accès anonyme :

![nexus ](/assets/nexus_05.png)

- cliquez sur Terminer :

![nexus ](/assets/nexus_06.png)

![nexus ](/assets/nexus_07.png)
