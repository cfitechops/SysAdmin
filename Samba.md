# Samba

- Mettre à jour le système et installer les paquets nécessaires

```sh
sudo apt-get update
sudo apt-get install ssh -y
sudo apt-get install samba -y
```

- Vérifier l'état du service Samba

```sh
sudo systemctl status smbd
```

- Si le service n'est pas actif, démarrez-le avec

```sh
sudo systemctl start smbd
```

- Créer un répertoire partagé sécurisé

```sh
sudo mkdir -p /samba/public
sudo chmod -R 0750 /samba/public
sudo chown -R nobody:sambashare /samba/public
```

#### Explications :

- /samba/public : Répertoire partagé.

- **Permissions** 0750 :

  - L'utilisateur propriétaire a tous les droits (lecture, écriture, exécution).

  - Le groupe a accès en lecture/exécution.

  - Aucun accès pour "autres".

- **Propriétaire** nobody:sambashare :

  - Le propriétaire est nobody, mais seuls les membres du groupe sambashare peuvent accéder au partage.

- Ajoutez ensuite votre utilisateur au groupe sambashare

```sh
# Crée un nouvel utilisateur Linux.
sudo adduser sambauser

# Adding user `sambauser' ...
# Adding new group `sambauser' (1001) ...
# Adding new user `sambauser' (1001) with group `sambauser' ...
# Creating home directory `/home/sambauser' ...
# Copying files from `/etc/skel' ...
# Enter new UNIX password: ********
# Retype new UNIX password: ********
# passwd: password updated successfully
# Changing the user information for sambauser
# Enter the new value, or press ENTER for the default
#     Full Name []:
#     Room Number []:
#     Work Phone []:
#     Home Phone []:
#     Other []:
# Is the information correct? [Y/n] Y


# Ajoute l'utilisateur au groupe 'sambashare'.

sudo usermod -aG sambashare sambauser
```

- Ouvrez le fichier de configuration Samba pour le modifier

```sh
sudo nano /etc/samba/smb.conf
```

- Modifiez ou ajoutez les sections suivantes
  - Cette section configure les paramètres globaux de Samba

```sh
[global]
   workgroup = WORKGROUP        #Nom du groupe de travail (par défaut, "WORKGROUP").
   netbios name = ubuntu        #Nom du serveur visible sur le réseau.
   security = user              #Active l'authentification basée sur les utilisateurs.
   server string = %h server (Samba, Ubuntu)
   log file = /var/log/samba/%m.log  #Crée un fichier journal distinct pour chaque machine cliente.
   max log size = 1000               #Limite la taille des journaux à 1 Mo par fichier.

   interfaces = 127.0.0.0 enp0s3  #Limite Samba aux interfaces spécifiées (par exemple, enp0s8) pour éviter une exposition non désirée.
   bind interfaces only = yes
```

- Cette section configure le partage public sécurisé.

```sh
[public]
   #Chemin vers le répertoire partagé.
   path = /samba/public
   browseable = yes
    #Désactive l'accès invité.
   guest ok = no
   read only = no
   #Restreint l'accès aux membres du groupe sambashare.
   valid users = @sambashare
   force group = sambashare
   create mask = 0640
   directory mask = 0750
```

- Avant de redémarrer le service, vérifiez que votre fichier de configuration est valide

```sh
testparm
```

- Appliquez les modifications en redémarrant Samba

```sh
sudo systemctl restart smbd nmbd
```

- Créer des utilisateurs Samba
  - Pour un environnement professionnel, chaque utilisateur doit avoir son propre compte Samba. Voici comment créer un utilisateur et lui attribuer un mot de passe

```sh
# Configurez un mot de passe Samba pour cet utilisateur
sudo smbpasswd -a sambauser
```

- Remplacez sambauser par le nom d'utilisateur souhaité. Cela demandera de définir un mot de passe pour cet utilisateur

- Ajoutez ensuite cet utilisateur au groupe sambashare, s'il ne l'est pas déjà

```sh
sudo usermod -aG sambashare sambauser
```

#### Configurer le pare-feu

- Pour sécuriser davantage votre serveur, configurez un pare-feu afin que seules les connexions locales soient autorisées à accéder à Samba

- Autoriser uniquement les appareils du réseau local (par exemple, 192.168.1.0/24)

```sh
sudo ufw allow from 192.168.1.0/24 to any app Samba
```

- Activez ensuite le pare-feu si ce n'est pas déjà fait

```sh
sudo ufw enable
```

- Vérifiez que les règles ont bien été appliquées

```sh
sudo ufw status verbose
```

#### Tester l'accès au partage

- Depuis un autre appareil sur le même réseau, accédez au partage en utilisant son adresse IP. Par exemple, dans un explorateur de fichiers ou navigateur réseau

```sh
smb://192.168.1.x/public/
```

- Pour vérifier que tout fonctionne correctement, connectez-vous au serveur et créez un fichier dans le répertoire partagé

```sh
cd /samba/public/
sudo touch testfile.txt
ls -l /samba/public/
```

#### Note:

- Avec cette configuration, votre serveur Samba est maintenant sécurisé et prêt pour une utilisation professionnelle.
