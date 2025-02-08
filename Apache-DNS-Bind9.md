#### Configuration de l'interface réseau

- Attribuez une adresse IP statique à chaque serveur DNS. Voici un exemple pour le serveur primaire

```sh
sudo nano /etc/netplan/cfg-static-ip.yaml
```

- Ajoutez la configuration

```sh
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: false
      addresses:
        - 192.168.10.2/24
      routes:
        - to: default
          via: 192.168.10.1
      nameservers:
        addresses: [192.168.10.2, 8.8.8.8]
```

- Appliquez les modifications

```sh
sudo netplan apply
```

- Mise à jour du système

```sh
sudo apt update && sudo apt upgrade -y
```

- Installer Apache2

```sh
sudo apt install apache2 -y
```

- Vérifier le statut du service Apache

```sh
sudo systemctl status apache2
```

- Installer BIND9 (serveur DNS)

```sh
sudo apt install bind9 bind9utils bind9-doc iptables-persistent -y
sudo ufw allow bind9
```

#### Configuration du serveur web avec Apache2

- Créer le répertoire pour l'hôte virtuel

```sh
sudo mkdir /var/www/cfitech-it.com

# Changer le propriétaire du répertoire pour l'utilisateur actuel.
sudo chown -R $USER:$USER /var/www/cfitech-it.com

# Définir les permissions du répertoire.
sudo chmod -R 755 /var/www/cfitech-it.com
```

- Créer une page HTML de test

```sh
sudo nano /var/www/cfitech-it.com/index.html
```

- Ajoutez le contenu suivant

```sh
<h1>Bienvenue sur Cfitech</h1>
<p>cfitech-it.com</p>
```

#### Configurer un hôte virtuel pour HTTP

- Créez un fichier de configuration pour l'hôte virtuel

```sh
sudo nano /etc/apache2/sites-available/cfitech-it.com.conf
```

- Ajoutez le contenu suivant

```sh
<VirtualHost *:80>
    ServerAdmin admin@cfitech-it.com
    ServerName cfitech-it.com
    ServerAlias www.cfitech-it.com

    DocumentRoot /var/www/cfitech-it.com

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

#### Activer l'hôte virtuel et désactiver le site par défaut

- Activez la configuration de l'hôte virtuel

```sh
sudo a2ensite cfitech-it.com.conf
```

- Désactivez le site par défaut d'Apache

```sh
sudo a2dissite 000-default.conf
```

- Vérifiez la configuration Apache

```sh
sudo apache2ctl configtest
```

- Redémarrez Apache pour appliquer les modifications

```sh
sudo systemctl restart apache2
```

#### Configuration du serveur DNS avec BIND9

- Configurer une zone DNS pour cfitech-it.com
  - Modifiez ou créez le fichier /etc/bind/db.cfitech-it.com

```sh
sudo nano /etc/bind/db.cfitech-it.com
```

- Ajoutez le contenu suivant

```sh
$TTL    604800

@       IN      SOA     ns.cfitech-it.com. admin.cfitech-it.com. (
                        2025020801 ; Serial (à incrémenter à chaque modification)
                        3600       ; Refresh interval (1 heure)
                        900        ; Retry interval (15 minutes)
                        1209600    ; Expire interval (14 jours)
                        86400      ; Negative Cache TTL (1 jour)
)

@       IN      NS      ns.cfitech-it.com.
ns      IN      A       192.168.10.2   ; Adresse IP du serveur DNS primaire.
www     IN      A       192.168.10.3   ; Adresse IP du serveur web.
```

- Redémarrez BIND9 pour appliquer les modifications

```sh
sudo systemctl restart bind9 && sudo systemctl status bind9
```

#### Ajouter une entrée dans le fichier /etc/hosts sur les clients

- Sur les machines clientes (ou localement sur le serveur), ajoutez une entrée dans /etc/hosts pour résoudre cfitech-it.com sans dépendre d'un DNS externe

```sh
sudo nano /etc/hosts
```

- Ajoutez cette ligne

```sh
192.168.10.3 cfitech-it.com www.cfitech-it.com
```

#### Activer HTTPS avec un certificat auto-signé

- Activer le module SSL d'Apache et redémarrer le service

```sh
sudo a2enmod ssl
sudo systemctl restart apache2
```

#### Générer un certificat auto-signé

- Exécutez la commande suivante pour générer un certificat SSL valide pendant 365 jours

```sh
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/ssl/private/apache-selfsigned.key \
-out /etc/ssl/certs/apache-selfsigned.crt


--------------------------

Country Name : BE
State or Province Name : BXL
Locality Name : Koekelberg
Organization Name : Cfitech
Organizational Unit Name : IT
Common Name : cfitech-it.com
Email Address : admin@cfitech-it.com
```

#### Configurer l'hôte virtuel HTTPS

- Modifiez votre fichier /etc/apache2/sites-available/cfitech-it.com.conf

```sh
sudo nano /etc/apache2/sites-available/cfitech-it.com.conf
```

- Ajoutez ou remplacez par cette configuration HTTPS

```sh
<VirtualHost *:80>
    ServerName cfitech-it.com

    # Rediriger tout le trafic HTTP vers HTTPS.
    Redirect / https://cfitech-it.com/
</VirtualHost>

<VirtualHost *:443>
    SSLEngine on

    SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
    SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key

    ServerAdmin admin@cfitech.it
    ServerName cfitech-it.com
    ServerAlias www.cfitech-it.com

    DocumentRoot /var/www/cfitech-it.com

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

#### Vérifier la configuration et redémarrer Apache

- Vérifiez qu'il n'y a pas d'erreurs dans la configuration Apache

```sh
sudo apache2ctl configtest
```

- Rechargez Apache pour appliquer les modifications

```sh
sudo systemctl reload apache2 && sudo systemctl restart apache2

# Désactivez également le site par défaut si ce n'est pas encore fait.
sudo a2dissite 000-default.conf
```

#### Tests et Vérifications

- Tester la résolution DNS depuis un client ou un autre serveur
  - Résolution directe (A)

```sh
nslookup cfitech-it.com 192.168.10.2
dig @192.168.10.2  cfitech-it.com
ping cfitech-it.com
```

- Résolution inverse (PTR) (si configurée)

```sh
dig -x 192.168.10.2
nslookup 192.168.10.2
```

#### Accès via HTTP (redirection vers HTTPS)

- Dans un navigateur ou avec curl

```sh
curl http://cfitech-it.com
curl -k https://cfitech-it.com
```

#### Note:

- serveur DNS fonctionnel, d'un site web accessible via HTTP et HTTPS, ainsi que d'une infrastructure sécurisée prête à être utilisée dans un environnement professionnel.
