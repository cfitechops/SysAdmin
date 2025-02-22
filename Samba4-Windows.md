# SAMBA 4 ACTIVE DIRECTORY DOMAIN CONTROLLER EN UBUNTU SERVER + UNION WINDOWS 10

## Configuration du serveur

#### Changer le hostname

```sh
sudo hostnamectl set-hostname dc
```

#### Modifier le fichier hosts

```sh
sudo nano /etc/hosts
```

```sh
192.168.1.8 dc.cfitech.local dc
192.168.1.8 cfitech.local cfitech
```

#### Vérifier le FQDN

```sh
hostname -f
```

#### Vérifier si le FQDN peut résoudre l'adresse IP de Samba

```sh
ping -c4 dc.cfitech.local
```

#### Désactiver le service systemd-resolved

```sh
sudo systemctl disable --now systemd-resolved
```

#### Supprimer le lien symbolique vers /etc/resolv.conf

```sh
sudo unlink /etc/resolv.conf
```

#### Créer un nouveau fichier /etc/resolv.conf

```sh
sudo nano /etc/resolv.conf
```

```sh
nameserver 192.168.1.8
nameserver 8.8.8.8
search cfitech.local
```

#### Rendre /etc/resolv.conf immuable

```sh
sudo chattr +i /etc/resolv.conf
```

## INSTALLATION DE SAMBA

```sh
sudo apt update

# Installer Samba avec ses paquets et dépendances
sudo apt install -y acl attr samba samba-dsdb-modules samba-vfs-modules smbclient winbind libpam-winbind libnss-winbind libpam-krb5 krb5-config krb5-user dnsutils chrony net-tools
```

```sh
CFITECH.LOCAL
dc.cfitech.local
dc.cfitech.local
```

#### Arrêter et désactiver les services non nécessaires pour Active Directory

```sh
sudo systemctl disable --now smbd nmbd winbind
```

#### Le serveur n'a besoin que de samba-ad-dc pour fonctionner comme Active Directory

```sh
sudo systemctl unmask samba-ad-dc
sudo systemctl enable samba-ad-dc
```

## CONFIGURATION DE SAMBA ACTIVE DIRECTORY

#### Créer une sauvegarde du fichier /etc/samba/smb.conf

```sh
sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.orig
```

#### Exécuter la commande samba-tool pour commencer à provisionner Samba Active Directory

```sh
sudo samba-tool domain provision

# -----------------------------------------

Realm: CFITECH.LOCAL
Domain: CFITECH:
Server Role: dc:
DNS backend: SAMBA_INTERNAL
DNS forwarder IP address: 8.8.8.8
Administrator password:
Retype password:
```

#### Créer une sauvegarde de la configuration par défaut de kerberos

```sh
sudo mv /etc/krb5.conf /etc/krb5.conf.orig
```

#### Remplacer par le fichier /var/lib/samba/private/krb5.conf

```sh
sudo cp /var/lib/samba/private/krb5.conf /etc/krb5.conf
```

#### Démarrer le service Samba Active Directory samba-ad-dc

```sh
sudo systemctl start samba-ad-dc
```

#### Vérifier le service

```sh
sudo systemctl status samba-ad-dc
```

## CONFIGURER LA SYNCHRONISATION HORAIRE

- Samba Acive Directory dépend du protocole Kerberos, et le protocole Kerberos nécessite que les heures du serveur AD et du poste de travail soient synchronisées. Pour garantir une bonne synchronisation de l'heure, nous devrons également configurer un serveur NTP (Network Time Protocol) dans Samba. Les avantages de la synchronisation temporelle AD incluent la prévention des attaques par relecture et la résolution des conflits de réplication AD.

- Modifiez l'autorisation et la propriété par défaut du répertoire /var/lib/samba/ntp_signd/ntp_signed. L'utilisateur/groupe chrony doit avoir l'autorisation de lecture sur le répertoire ntp_signed.

#### Change permissions for NTP signed directory

```sh
sudo chown root:_chrony /var/lib/samba/ntp_signd/
sudo chmod 750 /var/lib/samba/ntp_signd/
```

#### Modify chrony configuration

```sh
sudo nano /etc/chrony/chrony.conf
```

```sh
bindcmdaddress 192.168.1.8
allow 192.168.1.0/24
ntpsigndsocket /var/lib/samba/ntp_signd
```

#### Restart and verify chronyd service

```sh
sudo systemctl restart chronyd
sudo systemctl status chronyd
```

## CONFIGURER LA SYNCHRONISATION DU TEMPS

#### Changer les permissions et la propriété du répertoire /var/lib/samba/ntp_signd/

```sh
sudo chown root:_chrony /var/lib/samba/ntp_signd/
sudo chmod 750 /var/lib/samba/ntp_signd/
```

#### Modifier le fichier de configuration /etc/chrony/chrony.conf

```sh
sudo nano /etc/chrony/chrony.conf
```

```sh
bindcmdaddress 192.168.1.8
allow 192.168.1.0/24
ntpsigndsocket /var/lib/samba/ntp_signd
```

#### Redémarrer et vérifier le service chronyd

```sh
sudo systemctl start chronyd
sudo systemctl status chronyd
```

```sh
host -t A cfitech.local
host -t A dc.cfitech.local
```

## VÉRIFIER SAMBA ACTIVE DIRECTORY

#### Vérifier les noms de domaine

```sh
host -t A cfitech.local
host -t A dc.cfitech.local
```

#### Vérifier que les enregistrements de service kerberos et ldap pointent vers le FQDN

```sh
host -t SRV _kerberos._udp.cfitech.local
host -t SRV _ldap._tcp.cfitech.local
```

#### Vérifier les ressources par défaut disponibles dans Samba AD

```sh
smbclient -L cfitech.local -N
```

#### Vérifier l'authentification sur le serveur kerberos avec l'administrateur

```sh
kinit administrator@cfitech.LOCAL
klist
```

#### Se connecter au serveur via smb

```sh
sudo smbclient //localhost/netlogon -U 'administrator'
smb: \> exit
```

#### Changer le mot de passe de l'utilisateur administrator

```sh
sudo samba-tool user setpassword administrator
```

#### Vérifier l'intégrité du fichier de configuration de Samba

```sh
testparm
```

#### Vérifier le fonctionnement WINDOWS AD DC 2008

```sh
sudo samba-tool domain level show
```

#### Créer un utilisateur SAMBA AD

```sh
sudo samba-tool user create tspcr
```

#### Lister les utilisateurs SAMBA AD

```sh
sudo samba-tool user list
```

#### Supprimer un utilisateur

```sh
sudo samba-tool user delete <username>
```

#### Lister les ordinateurs SAMBA AD

```sh
sudo samba-tool computer list
```

#### Supprimer un ordinateur SAMBA AD

```sh
sudo samba-tool computer delete <number_delete_pc>
```

#### Créer un groupe

```sh
sudo samba-tool group add <number_del_group>
```

#### Lister les groupes

```sh
sudo samba-tool group list
```

#### Lister les membres d'un groupe

```sh
sudo samba-tool group listmembers 'Domain Admins'
```

## Pour le client Windows

- Accédez à cfitech.local en utilisant les informations d'identification d'administrateur

- Rejoindre le domaine avec un nouvel utilisateur (par exemple, tspcr) Sur le serveur, vérifiez le nouvel ordinateur

```sh
# Accès

cfitech.local
(administrator, password)


(cfitech.local\tspcr ; password)
```

#### Note:

- Ce code couvre l'installation, la configuration et la vérification d'un contrôleur de domaine Samba Active Directory sur Ubuntu Server, ainsi que l'intégration avec Windows.
