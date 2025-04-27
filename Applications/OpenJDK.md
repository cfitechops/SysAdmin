# OpenJDK

- Java est un langage polyvalent et puissant offrant un large éventail d'applications. Son indépendance vis-à-vis de la plateforme, son orientation objet, sa bibliothèque standard riche et son écosystème étendu en font un choix judicieux pour les développeurs développant des applications de toutes tailles, des plus petites aux plus grands systèmes d'entreprise.

- **Étape 1** : Installer OpenJDK sur Ubuntu 24.04
  - Utilisez les commandes ci-dessous pour installer OpenJDK sur Ubuntu 24.04 LTS

```sh
sudo apt update
```

- Pour rechercher toutes les versions `Java` disponibles dans le référentiel de packages Ubuntu.

```sh
apt search openjdk | grep -E 'openjdk-.*-jdk/'
```

- Installez **openjdk-21-jdk ( Java Development Kit )** à l'aide de la commande ci-dessous.

```sh
sudo apt install openjdk-21-jdk
```

- Vérifiez la version Java pour l'exécution et le compilateur.

```sh
java --version
javac --version
```

- Utilisez la commande `wget` suivante pour télécharger Oracle Java 22 sur Ubuntu 24.04 LTS

```sh
wget https://download.oracle.com/java/22/latest/jdk-22_linux-x64_bin.deb
```

- Utilisez la commande `dpkg` suivante pour installer le fichier d'installation Oracle Java qui inclut les binaires et les fichiers nécessaires pour exécuter le kit de développement Java sur votre système.

```sh
sudo dpkg -i jdk-22_linux-x64_bin.deb
```

- Encore une fois, nous devons vérifier la version Java

```sh
java --version
javac --version
```

- Répertoriez toutes les versions Java disponibles installées sur votre système.

```sh
update-alternatives --list java
```

- Pour basculer entre différentes versions de Java, utilisez la commande suivante.

```sh
sudo update-alternatives --config java
```
