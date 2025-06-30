# Web Server avec Apache sur Ubuntu Server

#### Installation d'Apache

```sh
sudo apt install apache2 -y
```

#### Vérification du statut d’Apache

```sh
sudo systemctl status apache2
```

#### Création du répertoire pour le site

```sh
sudo mkdir /var/www/medium.diarabaka.local
sudo chown -R $USER:$USER /var/www/medium.diarabaka.local
sudo chmod -R 755 /var/www/medium.diarabaka.local
```

#### Page d’exemple

```sh
sudo nano /var/www/medium.diarabaka.local/index.html
```

- Contenu

```sh
<h1>Hello Apache2 PROX</h1>
```

#### Fichier de configuration

```sh
sudo nano /etc/apache2/sites-available/medium.diarabaka.local.conf
```

- Contenu initial

```sh
<VirtualHost *:80>
    ServerAdmin medium@diarabaka.local
    ServerName medium.diarabaka.local
    ServerAlias www.medium.diarabaka.local
    DocumentRoot /var/www/medium.diarabaka.local
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

#### Activation de la configuration

```sh
sudo a2ensite medium.diarabaka.local.conf
sudo a2dissite 000-default.conf
sudo apache2ctl configtest
sudo systemctl restart apache2
```

#### Fichier hosts (poste local ou serveur)

```sh
sudo nano /etc/hosts
```

- Ajouter

```sh
192.168.129.172 medium.diarabaka.local
```

#### Zone DNS locale avec BIND9

```sh
sudo nano /etc/bind/zones/db.diarabaka.local
```

- Contenu

```sh
medium.diarabaka.local  IN  A  192.168.129.172
```

```sh
sudo systemctl restart bind9
sudo systemctl status bind9
```

## Activer HTTPS avec certificat auto-signé

#### Activation du module SSL

```sh
sudo a2enmod ssl
sudo systemctl restart apache2
```

#### Génération du certificat SSL

```sh
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/ssl/private/apache-selfsigned.key \
-out /etc/ssl/certs/apache-selfsigned.crt
```

#### Répondez aux questions

```sh
Country Name (2 letter code) [AU]:BE
State or Province Name (full name) [Some-State]:BXL
Locality Name (eg, city) []:Koekelberg
Organization Name (eg, company) [Internet Widgits Pty Ltd]:Diarabaka
Organizational Unit Name (eg, section) []:IT
Common Name (e.g. server FQDN or YOUR name) []:Sys-Admin
Email Address []:admin@gmail.com
```

#### Modifier le Virtual Host avec HTTPS

```sh
sudo nano /etc/apache2/sites-available/medium.diarabaka.local.conf
```

- Contenu

```sh
<VirtualHost *:80>
    ServerName medium.diarabaka.local
    Redirect / https://medium.diarabaka.local/
</VirtualHost>

<VirtualHost *:443>
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
    SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key

    ServerAdmin medium@diarabakacomputer.local
    ServerName medium.diarabaka.local
    ServerAlias www.medium.diarabaka.local
    DocumentRoot /var/www/medium.diarabaka.local
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

#### Test et rechargement

```sh
sudo apache2ctl configtest
sudo systemctl reload apache2
sudo a2dissite 000-default
```

- `https://medium.diarabaka.local` est maintenant opérationnel avec HTTPS sécurisé (certificat auto-signé).