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

- Création de l'utilisateur john, du groupe smbgroup et du dossier partagé

```sh
sudo adduser john
sudo groupadd smbgroup
sudo mkdir /home/group
sudo chgrp smbgroup /home/group
sudo chmod 770 /home/group
sudo chmod g+s /home/group
```

#### Sauvegarde et édition du fichier de configuration Samba

- Sauvegarde du fichier de config Samba et édition

```sh
cd /etc/samba/
sudo cp smb.conf smb.conf.bak
sudo nano smb.conf
```

- les lignes à ajouter ou modifier dans le fichier smb.con

```sh
[global]
workgroup = WORKGROUP
security = user
interfaces = lo enp0s3
bind interfaces only = yes

[homes]
comment = Dossiers personnels
path = /home/%S
valid users = %S
read only = no
create mask = 0700
directory mask = 0700
browseable = no

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

- Configuration des droits et ajout de john au groupe smbgroup

```sh
sudo chmod 755 /home/john
sudo smbpasswd -a john
sudo usermod -aG smbgroup john
```

#### Vérification de la config Samba

```sh
testparm
```

#### Redémarrage du service Samba et ouverture du pare-feu

```sh
sudo systemctl restart smbd
sudo systemctl status smbd
sudo ufw enable
sudo ufw allow samba
```

#### Test de connexion avec smbclient

- Test d’accès avec smbclient (depuis la machine locale)

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

#### Ajout d'un autre utilisateur alice et intégration dans smbgroup

```sh
sudo adduser alice --home /home/alice
sudo smbpasswd -a alice
sudo usermod -aG smbgroup alice
```

- `Test avec un utilisateur non membre du groupe` pour vérifier le contrôle d’accès.
  - Doit retourner une erreur d'accès refusé (NT_STATUS_ACCESS_DENIED)

```sh
sudo adduser bob
sudo smbpasswd -a bob
smbclient //192.168.129.152/Group -U bob
```