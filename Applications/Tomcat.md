# Tomcat

- Tomcat est un conteneur de servlets Java gratuit et open source, une application logicielle qui exécute des pages JSP (Java Server Pages) et des servlets Java. Il est largement utilisé pour le déploiement d'applications web Java.

- **Étape 1** : Installer Java sur Ubuntu 24.04 LTS

  - Pour installer Tomcat, vous devez avoir Java installé. Tomcat s'appuie sur Java pour fonctionner.

- Commencez par mettre à jour le référentiel de packages.

```sh
sudo apt update
```

- Installer Openjdk (Java).

```sh
sudo apt install openjdk-17-jdk
```

- **Étape 2** : Créer un utilisateur Tomcat
  - Pour des raisons de sécurité, il est préférable de ne pas exécuter Tomcat en tant qu'utilisateur root. Créons un utilisateur et un groupe dédiés.

```sh
sudo useradd -m -U -d /opt/tomcat -s /bin/false tomcat
```

- Cette commande crée un utilisateur nommé `tomcat` avec un répertoire personnel dans `/opt/tomcat` . Le shell `/bin/false` empêche l'accès à la connexion.

- **Étape 3** : Installer Tomcat sur Ubuntu 24.04 LTS
  - Installons maintenant Tomcat. Rendez-vous d'abord sur le site officiel de Tomcat et [téléchargez la dernière version de Tomcat 10](https://tomcat.apache.org/download-10.cgi). Vous pouvez utiliser `wget` pour cela.

```sh
sudo wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.40/bin/apache-tomcat-10.1.40.tar.gz -P /tmp
```

- extrayez-le dans le répertoire `/opt/tomcat` .

```sh
sudo tar -xvf /tmp/apache-tomcat-10.1.40.tar.gz -C /opt/tomcat
```

- **Étape 4** : Mettre à jour les autorisations de Tomcat
  - Modifiez la propriété du répertoire Tomcat en l'attribuant à l' utilisateur et au groupe Tomcat :

```sh
sudo chown -R tomcat:tomcat /opt/tomcat
```

- **Étape 5** : Configurer Tomcat en tant que service

  - Un fichier d'unité systemd indique à systemd comment gérer un service. Créez un fichier nommé `tomcat.service` dans le répertoire `/etc/systemd/system` à l'aide d'un éditeur de texte.

- accédez au fichier `/etc/systemd/system` .

```sh
cd /etc/systemd/system
```

- Créez un fichier tomcat.service à l’aide de la commande nano

```sh
sudo nano tomcat.service
```

- ajoutez-y le contenu suivant.

```sh
[Unit]
Description=Tomcat Server
After=network.target

[Service]
Type=forking
User=tomcat
Group=tomcat
Environment="JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64"
WorkingDirectory=/opt/tomcat/apache-tomcat-10.1.40
ExecStart=/opt/tomcat/apache-tomcat-10.1.40/bin/startup.sh

[Install]
WantedBy=multi-user.target
```

- Enregistrez et fermez le fichier.
- Ajustez le chemin de la variable d’environnement `JAVA_HOME` en fonction de l’emplacement d’installation de votre `OpenJDK`.

- **Étape 6** : rechargez systemd et démarrez Tomcat
  - Rechargez le démon systemd pour appliquer les modifications.

```sh
sudo systemctl daemon-reload
```

- Démarrez le service Tomcat.

```sh
sudo systemctl start tomcat
```

- Activer Tomcat pour démarrer au démarrage.

```sh
sudo systemctl enable tomcat
```

- Vous pouvez maintenant vérifier le bon fonctionnement de votre service en saisissant votre `adresse IP publique avec le port 8080`, qui est le port par défaut de Tomcat, dans l'URL. Si tout est correctement configuré, la page d'accueil de Tomcat devrait s'afficher.

![tomcat](/assets/tomcat.png)
