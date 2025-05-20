# Mise en place d’un partage Samba sécurisé avec gestion des utilisateurs

- L’objectif de cette procédure est de configurer un partage réseau Samba sur un système Linux, accessible uniquement par les membres d’un groupe spécifique. Nous allons :

  - 1 - Installer Samba,

  - 2 - Créer un utilisateur et un groupe,

  - 3 - Configurer un répertoire partagé avec les bonnes permissions,

  - 4 - Modifier le fichier de configuration Samba,

  - 5 - Tester l’accès au partage.

#### Installation de Samba

```sh
sudo apt update
sudo apt install samba -y
samba --version
```

#### Création d’un utilisateur et préparation des dossiers

- Nous créons un utilisateur john, un répertoire partagé `/home/grou`p, et un groupe système `smbgroup` pour contrôler l’accès.

```sh
sudo adduser john
cd /home/
sudo mkdir group
sudo groupadd smbgroup
sudo chgrp smbgroup /home/group/
sudo chmod 770 /home/group/
```

#### Sauvegarde et édition du fichier de configuration Samba

- Nous sauvegardons le fichier d’origine, puis l’éditons pour ajouter deux partages : un personnel (homes) et un partagé (Group).

```sh
cd /etc/samba/
sudo cp smb.conf smb.conf.bak
sudo nano smb.conf
```

- les lignes à ajouter ou modifier dans le fichier smb.con

```sh
# ===========================
# CONFIGURATION GLOBALE
# ===========================
[global]
# Groupe de travail Windows par défaut
workgroup = WORKGROUP

# Mode de sécurité : authentification par utilisateur
security = user

# Interfaces autorisées : localhost et interface réseau enp0s3
interfaces = 127.0.0.0/8 enp0s3
bind interfaces only = yes


# ===========================
# PARTAGE DES DOSSIERS HOME
# ===========================
[homes]
comment = Dossiers personnels
path = /home/%S
valid users = %S
read only = no
create mask = 0700
directory mask = 0700
browseable = no


# =====================================
# PARTAGE COMMUN POUR LES COLLABORATEURS
# =====================================
[Group]
comment = Partage commun pour les membres du groupe smbgroup
path = /home/group
writable = yes
guest ok = no
valid users = @smbgroup
force create mode = 0770
force directory mode = 0770
inherit permissions = yes
```

#### Configuration des droits d’accès

- Nous définissons les permissions sur le répertoire personnel de `john`, ajoutons un mot de passe Samba, et plaçons `john` dans le groupe `smbgroup`.

```sh
sudo chmod 755 /home/john/
sudo smbpasswd -a john
sudo usermod -aG smbgroup john
```

#### Vérifie la configuration

```sh
testparm
```

#### Redémarrage de Samba et ouverture du pare-feu

```sh
sudo systemctl restart smbd
sudo systemctl status smbd
sudo ufw allow samba
```

#### Test de connexion avec smbclient

- Installons l’outil `smbclient` pour tester l’accès depuis la machine locale

```sh
sudo apt install smbclient
smbclient //192.168.129.152/Group -U john
```

- Une fois connecté:

```sh
smb: \> mkdir testfolder
smb: \> put /etc/hosts hosts.txt
smb: \> dir
```

- Nous devrions voir les fichiers créés et transférés dans le partage.

#### À tester ensuite (recommandé)

- Connexion depuis un `poste Windows` :
  - Ouvrir l’explorateur de fichiers et saisir `\\192.168.129.152\Group`, puis se connecter avec l’utilisateur `john`.

#### Ajout d’autres utilisateurs

```sh
sudo adduser alice
sudo smbpasswd -a alice
sudo usermod -aG smbgroup alice
```

- `Test avec un utilisateur non membre du groupe` pour vérifier le contrôle d’accès.
