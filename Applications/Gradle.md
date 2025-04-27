# Gradle

- Gradle est une évolution de l'automatisation de la construction. Gradle permet d'automatiser la construction, les tests, la publication, le déploiement, etc., de progiciels ou d'autres types de projets, tels que la génération de sites web statiques, la documentation générée, etc.

- **Étape 1** : Installer OpenJDK 21 sur Ubuntu 24.04 LTS
  - Gradle nécessite Java pour fonctionner. Assurez-vous que Java est installé sur votre système.

```sh
sudo apt update
sudo apt install openjdk-21-jdk
```

- vérifier la version Java.

```sh
java -version
```

- **Étape 2** : Téléchargez et installez Gradle sur Ubuntu 24.04 LTS
  - Téléchargez la distribution binaire Gradle sur Ubuntu 24.04 LTS

```sh
wget https://services.gradle.org/distributions/gradle-8.10-bin.zip -P /tmp
```

- Installez unzip sur Ubuntu s'il n'est pas installé.

```sh
sudo apt install unzip
```

- Décompressez le fichier téléchargé.

```sh
sudo unzip -d /opt/gradle /tmp/gradle-8.10-bin.zip
```

- **Étape 3** : Configurer les variables d'environnement Gradle sur Ubuntu 24.04 LTS
  - Créer un nouveau script de variable d'environnement pour Gradle

```sh
 sudo vi /etc/profile.d/gradle.sh
```

- Ajoutez les lignes ci-dessous au script

```sh
export GRADLE_HOME=/opt/gradle/gradle-8.10
export PATH=${GRADLE_HOME}/bin:${PATH}
```

- Rendre le script exécutable.

```sh
sudo chmod +x /etc/profile.d/gradle.sh
```

- Appliquer les modifications.

```sh
source /etc/profile.d/gradle.sh
```

- **Étape 4** : Vérifier l’installation de Gradle
  - vérifiez la version pour gradle.

```sh
gradle -v
```
