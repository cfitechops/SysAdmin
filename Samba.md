# Samba

#### Installer Samba et Mettre à Jour le Système

- Commencez par mettre à jour le système et installer Samba

```sh
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install samba -y
```

- Vérifiez que le service Samba est actif

```sh
sudo systemctl status smbd
```

- Créez un répertoire pour le partage Samba, par exemple /samba/share

```sh
sudo mkdir -p /samba/share
```

- Attribuez les permissions nécessaires au répertoire

```sh
sudo chown -R cfitech1:sambashare /samba/share
sudo chmod -R 0750 /samba/share
```

- **0750** : Le propriétaire a tous les droits (lecture, écriture, exécution), les membres du groupe ont seulement les droits de lecture et d'exécution, et les autres n'ont aucun accès.

- Ouvrez le fichier de configuration de Samba

```sh
sudo nano /etc/samba/smb.conf
```

- Configuration Globale Professionnelle

  - Dans la section [global], configurez les options suivantes pour renforcer la sécurité et optimiser le serveur

```sh
[global]
   workgroup = WORKGROUP                # Nom du groupe de travail Windows par défaut.
   netbios name = ubuntu                # Nom du serveur sur le réseau.
   security = user                      # Forcer l'authentification des utilisateurs.
   server min protocol = SMB3           # Utiliser SMB3 pour plus de sécurité.
   server signing = mandatory           # Activer la signature des paquets pour éviter les attaques MITM.
   encrypt passwords = true             # Chiffrer les mots de passe.
   log file = /var/log/samba/log.%m     # Activer les journaux pour déboguer.
   max log size = 1000                  # Taille maximale des journaux.
   map to guest = never                 # Désactiver complètement l'accès invité.
   interfaces = 192.168.1.8/24 wlp3s0 lo  # Limiter Samba à une interface réseau spécifique.
   bind interfaces only = yes           # Bloquer l'accès sur d'autres interfaces non spécifiées.
```

- Ajoutez une section pour votre partage professionnel

```sh
[share]
   path = /samba/share           # Chemin du répertoire partagé.
   browseable = no                      # Ne pas afficher dans les explorateurs réseau (optionnel).
   valid users = cfitech1           # Restreindre l'accès à l'utilisateur spécifié.
   read only = no                       # Permettre la modification des fichiers.
   create mask = 0640                   # Permissions par défaut pour les fichiers créés.
   directory mask = 0750                # Permissions par défaut pour les dossiers créés.
```

- Enregistrez et fermez le fichier (Ctrl + O, puis Ctrl + X).

- Ajoutez un utilisateur Linux (si ce n'est pas déjà fait)

```sh
sudo adduser cfitech1
```

- Ensuite, ajoutez cet utilisateur à Samba et définissez un mot de passe Samba sécurisé

```sh
sudo smbpasswd -a cfitech1
```

- Activez l'utilisateur dans Samba

```shh
sudo smbpasswd -e cfitech1
```

- Testez votre fichier de configuration pour détecter d'éventuelles erreurs

```sh
testparm
```

- Si tout est correct, redémarrez le service Samba pour appliquer les modifications

```sh
sudo systemctl restart smbd nmbd
```

- Pour accéder au partage depuis un autre ordinateur (Windows, macOS ou Linux), utilisez l'adresse suivante dans votre explorateur réseau ou gestionnaire de fichiers

```sh
\\192.168.1.8\share\
```

- Si vous êtes sur Linux, utilisez

```sh
smb://192.168.1.8/share/
```

- Un écran d'authentification apparaîtra. Entrez le nom d'utilisateur (cfitech1) et le mot de passe Samba que vous avez configurés

- Pour surveiller l'activité ou diagnostiquer des problèmes, consultez les journaux Samba

```sh
sudo tail -f /var/log/samba/log.*
```

#### Note:

- Avec cette configuration, votre serveur Samba est sécurisé et prêt à être utilisé.
