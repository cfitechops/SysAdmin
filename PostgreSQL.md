# PostgreSQL 

- PostgreSQL, souvent appelé Postgres, est un puissant système de gestion de bases de données relationnelles open source, reconnu pour sa robustesse, ses performances et ses fonctionnalités avancées. Il est plébiscité par les développeurs et les entreprises.

- PostgreSQL prend en charge un large éventail de types de données et de fonctionnalités d'optimisation des performances, ce qui le rend idéal pour gérer des relations de données complexes et des applications critiques.

#### Installer PostgreSQL sur Ubuntu 24.04 LTS

- Mettez à jour votre système

```sh
sudo apt update
```

- Installez PostgreSQL à l'aide du gestionnaire de paquets

```sh
sudo apt install -y postgresql-common -y
```

- Exécuter le script du référentiel PostgreSQL APT :

```sh
sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
```

- Installez le `PostgreSQL` package du serveur de base de données

```sh
sudo apt install -y postgresql
```

- Démarrez le serveur de base de données PostgreSQL

```sh
sudo systemctl restart postgresql
```

- Vérifier le statut

```sh
sudo systemctl status postgresql
```

#### Sécuriser le serveur de base de données PostgreSQL sur Ubuntu 24.04 LTS

- Connectez-vous au serveur de base de données PostgreSQL :

```sh
sudo -u postgres psql
```

- Modifier le mot de passe par défaut

```sh
ALTER USER postgres WITH ENCRYPTED PASSWORD 'strong_password';
```

- Créer un nouvel utilisateur `db_manager` avec un nouveau mot de passe

```sh
CREATE USER db_manager ENCRYPTED PASSWORD 'strong_password';
```

- Quitter la console `cntrl+d`

- Pour modifier la peer valeur par défaut `scram-sha-256` dans le `pg_hba.conf` fichier et activer l'authentification par mot de passe sur le serveur, exécutez la commande suivante :

```sh
sudo sed -i '/^local/s/peer/scram-sha-256/' /etc/postgresql/16/main/pg_hba.con
```

- Redémarrer le serveur

```sh
sudo systemctl restart postgresql
```

#### Accéder à la ligne de commande du serveur de base de données PostgreSQL

- Pour créer un nouvel exemple de table appelé `doctors` dans PostgreSQL sur Ubuntu 24.04, suivez ces étapes :

- Basculer vers l' `postgresutilisateur` (le superutilisateur PostgreSQL par défaut)

```sh
sudo -i -u postgres
```

- Accédez à l'invite PostgreSQL

```sh
psql
```

- après avoir donné la commande ci-dessus, il vous demandera le mot de passe
- Créer une base de données : si vous n'en avez pas encore, vous pouvez d'abord en créer une. Cette étape est facultative si vous utilisez la base de données PostgreSQL par défaut.

```sh
CREATE DATABASE sample_db;
```

- Connectez-vous à la base de données nouvellement créée

```sh
\c sample_db
```

- Créer le doctorstableau :
- Une fois connecté à la base de données souhaitée, vous pouvez créer la doctorstable.
- Créez une table `doctors` avec des colonnes telles que `id, name, specialization, experience_years,` et `phone`:

```sh
CREATE TABLE doctors (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    experience_years INT NOT NULL,
    phone VARCHAR(15)
);
```

- `id SERIAL PRIMARY KEY`: Clé primaire auto-incrémentée.
- `name VARCHAR(100)`: Nom du médecin (chaîne de 100 caractères maximum).
- `specialization VARCHAR(100)`: Spécialisation du médecin (chaîne de 100 caractères maximum).
- `experience_years INT`: Années d'expérience (entier).
- `phone VARCHAR(15)`: Numéro de téléphone du médecin (facultatif).

- Vous pouvez maintenant insérer des exemples de données dans le tableau pour le tester.

```sh
INSERT INTO doctors (name, specialization, experience_years, phone)
VALUES
    ('Dr. Sophie Martin', 'Cardiologie', 12, '+32423456789'),
    ('Dr. Jean Dupont', 'Neurologie', 8, '+32487654321');
```

- Après avoir inséré des données, vous pouvez interroger la table pour vérifier les enregistrements :

```sh
SELECT * FROM doctors;
```

- Pour quitter l'interface de ligne de commande PostgreSQL, tapez :

```sh
\q
```
