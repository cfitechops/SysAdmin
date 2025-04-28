# Configuration du serveur FTPS

- Ce projet configure un serveur FTP sécurisé (FTPS) avec VSFTPD sur Ubuntu en mode Bridge, offrant :

  - Chiffrement SSL/TLS via certificat auto-signé
  - Isolation des utilisateurs avec chroot
  - Authentification obligatoire (pas d'accès anonyme)
  - Compatibilité avec FileZilla, WinSCP et autres clients modernes

#### Réseau (Bridged Adapter)

![ftp](/assets/ftp.png)

- → En mode `Bridge`, le serveur apparaît comme un appareil indépendant sur le réseau local.

#### Mise à jour et installation

```sh
sudo apt update && sudo apt install vsftpd -y
```

#### Sauvegarde de la config originale

```sh
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.original
```

#### Configuration de base

```sh
sudo nano /etc/vsftpd.conf
```

```sh
# Réseau
listen=YES
listen_ipv6=NO

# Authentification
anonymous_enable=NO
local_enable=YES
write_enable=YES

# Sécurité
chroot_local_user=YES
chroot_list_enable=YES
chroot_list_file=/etc/vsftpd.chroot_list
allow_writeable_chroot=YES
secure_chroot_dir=/var/run/vsftpd/empty

# Mode passif
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=50000
pasv_address=172.78.0.20  # Remplacez par votre IP
```

#### Création utilisateur

```sh
sudo useradd -m -d /home/cfitech -s /bin/bash cfitech
sudo passwd mypassword
```

#### Autorisation chroot

```sh
echo "cfitech" | sudo tee /etc/vsftpd.chroot_list
```

#### Configuration SSL/TLS

```sh
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/vsftpd.pem \
    -out /etc/ssl/certs/vsftpd.pem \
    -subj "/C=FR/ST=Paris/L=Paris/O=MyOrg/CN=ftp-server"
```

#### Configuration SSL (ajout)

```sh
sudo nano /etc/vsftpd.conf
```

```sh
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

#### Configuration du firewall

```sh
sudo ufw enable
sudo ufw allow 20/tcp           # FTP Data (Actif)
sudo ufw allow 21/tcp           # FTP Control
sudo ufw allow 990/tcp          # FTPS Implicite
sudo ufw allow 40000:50000/tcp  # FTP Passif Ports
sudo ufw status
```

#### Redémarrage des services

```sh
sudo systemctl restart vsftpd
sudo systemctl enable vsftpd
sudo systemctl status vsftpd
```

#### Pour une sécurité maximale, ajoutez après installation :

```sh
sudo chmod 750 /home/cfitech
sudo chown -R cfitech:cfitech /home/cfitech/ftp
```

#### Test

```sh
curl -k --ssl-reqd ftp://localhost/ -u cfitech
curl -k --ssl-reqd ftp://localhost/ -u cfitech:mypassword
```
