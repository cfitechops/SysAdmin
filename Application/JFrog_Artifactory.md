# JFrog Artifactory

- JFrog Artifactory est un gestionnaire de dépôt universel prenant en charge un large éventail de types de packages. Il permet aux équipes DevOps de gérer efficacement les dépendances, de stocker et de partager les artefacts en toute sécurité, et d'automatiser les processus tout au long du cycle de développement logiciel. Grâce à cet ensemble de commandes simples, Artifactory sera opérationnel en un rien de temps.

#### Install JFrog sur Ubuntu 24.04 LTS | Configure JFrog on Ubuntu | Access JFrog on Web

- **Étape 1** : Mettez à jour votre système

```sh
sudo apt update
```

- **Étape 2** : Installer OpenJDK 8 sur Ubuntu 24.04 LTS
  - Artifactory nécessite Java pour fonctionner. Dans ce guide, nous installerons OpenJDK 8. Même si des versions plus récentes de Java sont disponibles, JFrog Artifactory 6.9.6 est compatible avec cette version.

```sh
sudo apt install openjdk-8-jdk -y
```

- **Étape 3** : Téléchargez JFrog Artifactory OSS sur Ubuntu 24.04 LTS
  - Téléchargez maintenant la version 6.9.6 de JFrog Artifactory OSS à partir du référentiel officiel JFrog Bintray en utilisant wget.

```sh
sudo wget https://jfrog.bintray.com/artifactory/jfrog-artifactory-oss-6.9.6.zip
```

- **Étape 4** : Installez Unzip (s'il n'est pas déjà installé) sur Ubuntu 24.04 LTS
  - Si vous ne l'avez pas unzipinstallé sur votre système, vous pouvez l'installer avec la commande suivante :

```sh
sudo apt install unzip -y
```

- **Étape 5** : Décompressez le package Artifactory
  - Une fois le téléchargement terminé, décompressez le package Artifactory dans le `/opt/` répertoire.

```sh
sudo unzip -o jfrog-artifactory-oss-6.9.6.zip -d /opt/
```

- **Étape 6**: Accédez au répertoire Artifactory
  - Accédez au répertoire Artifactory extrait :

```sh
cd /opt/artifactory-oss-6.9.6
```

- **Étape 7** : démarrer le service JFrog Artifactory sur Ubuntu 24.04 LTS
  - Pour démarrer JFrog Artifactory, exécutez le artifactory.shscript :

```sh
./bin/artifactory.sh start
```

- Une fois le script exécuté, JFrog Artifactory devrait être opérationnel sur votre serveur. Vous pouvez accéder à l'interface d'Artifactory en ouvrant un navigateur et en sélectionnant :

`http://<your-server-ip>:8081`

![JFrog](/assets/JFrog_01.png)

- Définir un nouveau mot de passe :

![JFrog](/assets/JFrog_02.png)

- Entrez les valeurs:

![JFrog](/assets/JFrog_03.png)

- Sélectionnez les types de packages que vous souhaitez créer :

![JFrog](/assets/JFrog_04.png)
![JFrog](/assets/JFrog_05.png)

- Cliquez sur le bouton `Terminer` . Le tableau de bord JFrog s'affichera.

![JFrog](/assets/JFrog_06.png)
