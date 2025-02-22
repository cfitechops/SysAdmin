# SAMBA 4 AD DC - INTEGRER UBUNTU DESKTOP DANS LE DOMAINE UBUNTU SERVER

## CONFIGURER UBUNTU DESKTOP

#### Installer SSH

```sh
sudo apt install ssh -y
```

#### Vérifier l'état de SSH

```sh
sudo systemctl status ssh
```

#### Changer le nom d'hôte du bureau

```sh
sudo hostnamectl set-hostname ud101
hostname -f # Pour vérifier le nom d'hôte complet.
```

#### Configurer le fichier /etc/hosts pour résoudre les noms du serveur AD

```sh
sudo nano /etc/hosts
```

```sh
192.168.1.8 cfitech.local cfitech
192.168.1.8 dc.cfitech.local dc
```

#### Tester la connexion vers le serveur AD.

```sh
ping -c4 cfitech.local
```

#### Installer NTPDATE pour synchroniser l'heure avec le serveur

```sh
sudo apt-get install ntpdate
sudo ntpdate -q cfitech.local
sudo ntpdate cfitech.local
```

#### Installer les paquets nécessaires pour rejoindre un domaine Active Directory.

```sh
sudo apt-get install samba krb5-config krb5-user winbind libpam-winbind libnss-winbind
```

```sh
CFITECH.LOCAL
dc.cfitech.local
dc.cfitech.local
```

#### Vérifiez l'authentification sur le serveur Kerberos à l'aide de l'administrateur

```sh
kinit administrator@CFITECH.LOCAL # Authentifier via Kerberos.
klist # Afficher les tickets Kerberos.
```

#### Sauvegarder la configuration Samba existante.

```sh
mv /etc/samba/smb.conf /etc/samba/smb.conf.initial
```

#### Créer une nouvelle configuration Samba

```sh
nano /etc/samba/smb.conf
```

```sh
[global]
workgroup = CFITECH
realm = CFITECH.LOCAL
netbios name = ud101
security = ADS
dns forwarder = 192..68...18

idmap config * : backend = tdb
idmap config *: range =50000-1000000

template homedir = /home/%D/%U
template shell=/bin/bash

winbind use default domain=true
winbind offline logon=false
winbind nss info=rfc2307
winbind enum users=yes
winbind enum groups=yes

vfs objects=acl_xattr
map acl inherit=Yes
store dos attributes=Yes
```

#### Redémarrer les services Samba après modification de la configuration.

```sh
sudo systemctl restart smbd nmbd
```

#### Arrêter tout service inutile lié à samba-ad-dc sur ce client

```sh
sudo systemctl stop samba-ad-dc
```

#### Activer et démarrer automatiquement smbd et nmbd au démarrage du système

```sh
sudo systemctl enable smbd nmbd
```

#### Joindre Ubuntu Desktop au domaine Active Directory Samba.

```sh
sudo net ads join -U Administrator
```

#### Sur le serveur, lister tous les ordinateurs membres du domaine.

```sh
sudo samba-tool computer list
```

## DESKTOP CONFIGURER L'AUTHENTIFICATION DU COMPTE PUBLICITAIRE

#### Modifiez le fichier de configuration du commutateur de service de noms (NSS).

```sh
sudo nano /etc/nsswitch.conf
```

```sh
passwd         compat winbnd
group          compat winbnd
shadow         compat winbnd
gshadow        files

hosts          files dns
```

#### Reinicar servicio winbind

```sh
sudo systemctl restart winbnd
```

#### Listar usuarios y grupos del dominio.

```sh
wbinfo -u
wbinfo -g
```

#### Vérifiez le module winbind nsswitch avec la commande getent.

```sh
sudo getent passwd | grep administrator
sudo getent group | grep 'domain admins'
id administrator
```

#### Configurez pam-auth-update pour vous authentifier auprès des comptes de domaine

```sh
sudo pam-auth-update

# --> [*] Create home directory on login
```

#### Modifiez le fichier /etc/pam.d/common-account pour créer automatiquement une adresse

```sh
sudo nano /etc/pam.d/common-account
```

```sh
session  required  pam_mkhomedir.so  skel=/etc/skel/  umask=0022
```

#### Ajouter un compte de domaine avec les privilèges root

```sh
sudo usermod -aG sudo administrateur
```

#### Authentifiez-vous avec le compte Samba4 AD

```sh
su administrator
sudo su
```

#### Authentifier avec l'interface graphique

```sh
tspcr@cfitech.local

cd /home

ls
```

#### Note:

- Ce code permet d'intégrer un client Ubuntu Desktop dans un domaine Active Directory géré par un contrôleur de domaine Samba sur Ubuntu Server, y compris la configuration des services nécessaires comme Winbind et PAM pour l'authentification des comptes Active Directory localement sur le client Linux.
