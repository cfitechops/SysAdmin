# Serveur FTP sécurisé avec vsftpd (Very Secure FTP Daemon)

- Mettez à jour les paquets et installez vsftpd

```sh
sudo apt update
sudo apt install vsftpd -y
```

- Créez une sauvegarde du fichier de configuration par défaut pour pouvoir y revenir en cas de problème

```sh
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.original
```

- Ouvrez le fichier de configuration principal de vsftpd

```sh
sudo nano /etc/vsftpd.conf
```

- Ajoutez ou modifiez les lignes suivantes pour configurer un serveur FTP sécurisé

```sh
anonymous_enable=NO                       # Désactiver l'accès anonyme.
local_enable=YES                          # Autoriser les utilisateurs locaux à se connecter.
write_enable=YES                          # Permettre l'écriture pour les utilisateurs locaux.

chroot_local_user=YES                     # Isoler chaque utilisateur dans son répertoire personnel.
chroot_list_enable=YES                    # Activer une liste d'exceptions pour certains utilisateurs.
chroot_list_file=/etc/vsftpd.chroot_list  # Fichier contenant la liste des utilisateurs exemptés.
```

- Configurer la Liste des Utilisateurs Exemptés

```sh
sudo nano /etc/vsftpd.chroot_list
```

- Ajoutez le nom d'utilisateur suivant (ou tout autre utilisateur) dans le fichier

```sh
cfitech
```

- Redémarrez le service vsftpd pour appliquer les modifications

```sh
sudo systemctl restart vsftpd

sudo systemctl status vsftpd
```

- Activez le pare-feu UFW et ouvrez les ports nécessaires pour FTP et FTPS

```sh
sudo ufw enable                      # Activer UFW.
sudo ufw allow 20/tcp                # Port FTP pour les données.
sudo ufw allow 21/tcp                # Port FTP pour les commandes.
sudo ufw allow 990/tcp               # Port FTPS (FTP sécurisé).
sudo ufw allow 40000:50000/tcp       # Ports passifs pour les connexions FTP.
sudo ufw status                      # Vérifier l'état du pare-feu.
```

- Pour sécuriser les connexions FTP avec SSL/TLS, générez un certificat auto-signé avec OpenSSL

```sh
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/ssl/private/vsftpd.pem \
-out /etc/ssl/certs/vsftpd.pem
```

- **Note**: Pendant la génération du certificat, remplissez les informations demandées (pays, organisation, etc.).

- Ensuite, modifiez à nouveau le fichier /etc/vsftpd.conf pour activer FTPS

```sh
sudo nano /etc/vsftpd.conf
```

- Ajoutez ou modifiez les lignes suivantes

```sh
ssl_enable=YES                                     # Activer SSL/TLS.
rsa_cert_file=/etc/ssl/certs/vsftpd.pem            # Chemin du certificat SSL.
rsa_private_key_file=/etc/ssl/private/vsftpd.pem   # Chemin de la clé privée.

allow_anon_ssl=NO                  # Désactiver SSL pour les utilisateurs anonymes.
force_local_data_ssl=YES           # Forcer le chiffrement des données.
force_local_logins_ssl=YES         # Forcer le chiffrement des connexions.
ssl_tlsv1=YES                      # Activer TLS v1.0.
ssl_tlsv2=NO                       # Désactiver TLS v2.0 (obsolète).
ssl_tlsv3=NO                       # Désactiver TLS v3.0 (obsolète).
require_ssl_reuse=NO               # Désactiver la réutilisation des sessions SSL 
ssl_ciphers=HIGH                   # Utiliser uniquement des chiffrements forts.
```

- Redémarrez à nouveau le service vsftpd pour appliquer la configuration FTPS

```sh
sudo systemctl restart vsftpd
sudo systemctl status vsftpd
```

- Vous pouvez tester la connexion au serveur FTP localement à l'aide de la commande suivante

```sh
ftp localhost
```

- Entrez vos identifiants d'utilisateur local lorsque vous y êtes invité.

#### Test à Distance

- Depuis un client distant, utilisez un client FTP prenant en charge FTPS (comme FileZilla ou WinSCP) et configurez-le comme suit :

- **Hôte** : 192.168.x.x (adresse IP du serveur dans votre réseau local).
- **Port** : 21 pour FTP ou 990 pour FTPS.
- **Protocole** : FTPS explicite ou implicite selon votre client.

- Assurez-vous d'utiliser les identifiants d'un utilisateur local autorisé

#### Note:

- Serveur FTP est sécurisé et prêt à être utilisé. Vous pouvez gérer vos transferts de fichiers de manière sûre et efficace.
