# Créer un projet Java avec Maven

- Maven est un puissant outil d'automatisation de build, principalement utilisé pour les projets Java. Il simplifie le processus de build et gère les dépendances du projet, permettant aux développeurs de se concentrer sur le codage plutôt que sur la configuration.

- **Étape 1** : Configurer l'instance Ubuntu

  - Si vous n'avez pas installé JDK ou Maven sur votre système, vous pouvez l'installer en utilisant les commandes suivantes.

- Commencez par mettre à jour la liste des packages.

```sh
sudo apt update
```

- Spring Boot nécessite Java, installez donc OpenJDK.

```sh
sudo apt install openjdk-17-jdk -y
```

- Vérifiez l'installation de Java.

```sh
java -version
```

- Vous devriez voir les détails de la version de votre installation Java.

- Installons maintenant Maven. Maven est l'outil de build utilisé pour gérer les projets Java.

```sh
sudo apt install maven -y
```

- Vérifiez l’installation de Maven.

```sh
mvn -version
```

- **Étape 2** : Créer un projet Java avec Maven

  - Maven suit une structure de répertoire standard, ce qui facilite la gestion des projets. Pour créer un projet Maven, vous pouvez utiliser la ligne de commande.

  - Exécutez la commande suivante pour créer un nouveau projet.

```sh
mvn archetype:generate -DgroupId=com.example -DartifactId=myapp -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
```

- `groupId` : un identifiant unique pour votre projet (généralement le nom du package).
- `artifactId` : Le nom de votre projet.
- `archetypeArtifactId` : Le modèle du projet ; maven-archetype-quickstartcrée un projet Java simple.
- `interactiveMode` : définissez sur falsepour ignorer les invites interactives.

- Cette commande générera la structure de répertoire suivante.

```sh
myapp/
├── pom.xml
└── src
    ├── main
    │   └── java
    │       └── com
    │           └── example
    │               └── App.java
    └── test
        └── java
            └── com
                └── example
                    └── AppTest.java
```

- Accédez au répertoire du projet.

```sh
cd myapp
```

- Ouvrez le `pom.xml` fichier et mettez à jour le fichier pour les dépendances Spring Boot.

- Le `pom.xml` fichier (Project Object Model) est le cœur d'un projet Maven. Il contient les détails de configuration, tels que les dépendances, les paramètres de build et les informations sur le projet.

```sh
nano pom.xml
```

- remplacer son contenu par ce qui suit

```sh
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.example</groupId>
  <artifactId>myapp</artifactId>
  <packaging>jar</packaging>
  <version>1.0-SNAPSHOT</version>
  <name>myapp</name>
  <url>http://maven.apache.org</url>
  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>3.0.0</version>
    <relativePath />
  </parent>
  <dependencies>
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>3.8.1</version>
      <scope>test</scope>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-test</artifactId>
      <scope>test</scope>
    </dependency>
  </dependencies>
  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>
    </plugins>
  </build>
</project>
```

- **Étape 3** : Créer une application Spring Boot avec Maven

  - Créez un nouveau fichier nommé HelloworldApplication.javadans le src/main/java/com/examplerépertoire avec le contenu suivant :

  - Pour cela, accédez d'abord au répertoire.

```sh
cd src/main/java/com/example
```

- Créez un fichier nommé HelloworldApplication.java

```sh
nano MyappApplication.java
```

- Ajoutez-y le contenu suivant.

```sh
package com.example.myapp;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
public class MyappApplication {

    public static void main(String[] args) {
        SpringApplication.run(MyappApplication.class, args);
    }

    @RestController
    class MyappController {
        @GetMapping("/hello")
        public String hello() {
            return "Hello World!";
        }
    }
}
```

- **Étape 4** : Créer et exécuter l'application
  - quitter les répertoires jusqu'au répertoire racine de l'application.

```sh
cd ../../../../..
```

- Construisez l'application.

```sh
mvn clean install
mvn clean compile
mvn clean package
```

- **Explication**:

  - `clean` : supprime le targetrépertoire qui contient le code compilé et d'autres artefacts de construction.
  - `install` : compile le code, exécute les tests et empaquete l'application dans un fichier JAR, qui est stocké dans le targetrépertoire.

- Si tout est configuré correctement, vous devriez voir une sortie indiquant une construction réussie.

- Exécutez l’application à partir de la racine de votre répertoire de projet (où pom.xml trouve le fichier).

```sh
mvn spring-boot:run
```

- Sortir

![maven](/assets/maven.png)

- Accédez au point de terminaison Hello World. Pour cela, ouvrez votre navigateur web et exécutez :

```sh
http://<IP>:8080/hello
```
