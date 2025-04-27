# Maven

- Apache Maven est un outil permettant de créer et de gérer des projets basés sur Java.

- Dans un projet Java, vous devez gérer un fichier pom.xml . Il contient des informations sur le projet et la configuration utilisée par Maven pour générer le projet Java. Tous les éléments de votre build Maven sont définis dans ce fichier.

#### Vérifiez votre distribution Ubuntu

- Pour installer le bon package sur votre système basé sur Linux, tel qu'Ubuntu, vérifiez votre distribution

```sh
lsb_release -a
```

- Actualisez la liste des paquets de votre Ubuntu 24.04 via la commande ci-dessous :

```sh
sudo apt update
```

- **Étape 1** : Installer le kit de développement Java (JDK) sur Ubuntu 24.04 LTS
  - Grâce au package Java, Maven fonctionnera correctement. Vous devez donc configurer le package Java par défaut sur votre machine Ubuntu 24.04 via la commande suivante :

```sh
sudo apt install default-jdk -y
```

- **Étape 2** : Vérifier la version Java sur Ubuntu 24.04 à l'aide de la ligne de commande
  - Exécutons la commande suivante pour confirmer le package Java après son installation :

```sh
java -version
```

- **Étape 3** : Téléchargez Maven sur Ubuntu 24.04 LTS

  - Pour télécharger la dernière version du package Maven, visitez le [site officiel de Maven](https://maven.apache.org/download.cgi) et copiez le lien vers le binaire Maven :

- Utilisez simplement la commande `wget` suivie de l’URL du binaire Maven, comme mentionné ci-dessous, pour télécharger le package

```sh
wget https://dlcdn.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz
```

- **Étape 4** : Installer Maven sur Ubuntu 24.04 LTS
  - Ensuite, extrayez le package Maven dans le répertoire « /opt » à l’aide de cette commande simple :

```sh
sudo tar xf apache-maven-3.9.9-bin.tar.gz -C /opt
```

- **[Remarque]**: Si vous ne rencontrez aucune erreur dans votre sortie, cela indique que Maven a été extrait avec succès dans le répertoire « /opt » de votre système Ubuntu 24.04.

- **Étape 5** : Configurer les variables d'environnement Maven sur Ubuntu 24.04 LTS
  - Sous Ubuntu 24.04, la configuration des variables d'environnement est essentielle au bon fonctionnement de Maven. Par conséquent, vous devez créer un fichier « maven.sh » pour définir les variables d'environnement :

```sh
sudo nano /etc/profile.d/maven.sh
```

- Dans le fichier de script `maven.sh`, copiez les lignes de code ci-dessous :

```sh
export JAVA_HOME=/usr/lib/jvm/default-java
export M3_HOME=/opt/apache-maven-3.9.9
export MAVEN_HOME=/opt/apache-maven-3.9.9
export PATH=${M3_HOME}/bin:${PATH}
```

- Exécutez la commande suivante pour rendre le fichier `maven.sh` exécutable :

```sh
sudo chmod +x /etc/profile.d/maven.sh
```

- Enfin, vous devez exécuter le fichier `maven.sh` et appliquer les modifications sans redémarrer votre système :

```sh
source /etc/profile.d/maven.sh
```

- Pour vous assurer que le package Maven est correctement installé, vérifiez sa version :

```sh
mvn -version
```
