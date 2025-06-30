# Configuration du serveur FTPS

- Ce projet configure un serveur FTP sécurisé (FTPS) avec VSFTPD sur Ubuntu en mode Bridge, offrant :

  - Chiffrement SSL/TLS via certificat auto-signé
  - Isolation des utilisateurs avec chroot
  - Authentification obligatoire (pas d'accès anonyme)
  - Compatibilité avec FileZilla, WinSCP et autres clients modernes

- → En mode `Bridge`, le serveur apparaît comme un appareil indépendant sur le réseau local.

#### Mise à jour et installation

```sh
sudo apt update && sudo apt install vsftpd -y
```

#### Sauvegarde de la configuration originale

```sh
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.original
```

#### Configuration de vsftpd

```sh
sudo nano /etc/vsftpd.conf
```

- Ajoutez ou modifiez les lignes suivantes

```sh
# Réseau
listen=YES
listen_ipv6=NO

# Authentification
anonymous_enable=NO
local_enable=YES
write_enable=YES

# Sécurité et isolation
chroot_local_user=YES
chroot_list_enable=YES
chroot_list_file=/etc/vsftpd.chroot_list
allow_writeable_chroot=YES
secure_chroot_dir=/var/run/vsftpd/empty

# Mode passif
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=50000
pasv_address=172.78.0.20  # Remplacez par l’IP de votre serveur

# SSL/TLS
rsa_cert_file=/etc/ssl/certs/vsftpd.pem
rsa_private_key_file=/etc/ssl/private/vsftpd.pem
ssl_enable=YES
allow_anon_ssl=NO
force_local_data_ssl=YES
force_local_logins_ssl=YES
ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO
require_ssl_reuse=NO
ssl_ciphers=HIGH
```

#### Création de l'utilisateur FTP

```sh
sudo useradd -m -d /home/thierno -s /bin/bash thierno
sudo passwd thierno  # Définir le mot de passe
```

#### Autorisation dans le chroot

```sh
echo "thierno chroot" | sudo tee /etc/vsftpd.chroot_list
```

#### Génération du certificat SSL

```sh
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/vsftpd.pem \
  -out /etc/ssl/certs/vsftpd.pem \
  -subj "/C=FR/ST=Paris/L=Paris/O=MyOrg/CN=ftp-server"
```

#### Configuration du pare-feu UFW

```sh
sudo ufw allow 20/tcp           # FTP - Data
sudo ufw allow 21/tcp           # FTP - Control
sudo ufw allow 990/tcp          # FTPS implicite
sudo ufw allow 40000:50000/tcp  # Mode passif
sudo ufw enable
sudo ufw status
```

#### Redémarrage et activation du service

```sh
sudo systemctl restart vsftpd
sudo systemctl enable vsftpd
sudo systemctl status vsftpd
```

#### Sécurisation du dossier utilisateur

```sh
sudo chmod 750 /home/thierno
sudo mkdir -p /home/thierno/ftp
sudo chown -R thierno:thierno /home/thierno/ftp
```

#### Test de connexion FTPS

```sh
curl -k --ssl-reqd ftp://localhost/ -u thierno
```

#### Connexion avec mot de passe dans la commande (attention à la sécurité) :

```sh
curl -k --ssl-reqd ftp://localhost/ -u thierno:mypassword
```