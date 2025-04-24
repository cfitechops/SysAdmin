# Projet de Configuration d'un Serveur DNS Sécurisé (Bind9 avec DNSSEC) et d'un Serveur Web (Apache2 avec SSL)

#### Contexte

- Dans un environnement réseau, la sécurité des services DNS et Web est essentielle pour garantir :

  - **La confidentialité** : Protection contre l'espionnage et les attaques MITM (Man-in-the-Middle).
  - **L'intégrité** : Assurance que les données ne sont pas altérées en transit.
  - **La disponibilité** : Prévention des attaques par déni de service (DoS/DDoS).

- Ce projet vise à :

  - **Configurer un serveur DNS sécurisé** avec **Bind9** et **DNSSEC** pour authentifier les réponses DNS.
  - **Mettre en place un serveur Web Apache2** avec chiffrement **SSL/TLS** pour sécuriser les communications HTTP

#### Objectifs

- **DNS Sécurisé (DNSSEC)** :

  - Empêcher les attaques de **cache poisoning** (empoisonnement du cache DNS).
  - Valider l'authenticité des réponses DNS.

- **Serveur Web HTTPS** :

  - Chiffrer les échanges entre clients et serveur.
  - Protéger contre l'interception des données sensibles.

#### Topologie du Réseau

```sh
+-------------------+       +-------------------+       +-------------------+
|   Client (PC)     |  ⇄   |   Serveur DNS     |  ⇄   |   Internet          |
| (172.28.0.100)   |       | (Bind9 + DNSSEC) |       | (Google DNS 8.8.8.8)|
+-------------------+       | (172.28.0.2)    |       +-------------------+
                            |                   |
                            | Serveur Web       |
                            | (Apache2 + SSL)   |
                            +-------------------+
```

#### Flux des Requêtes

- **Requête DNS** (Client → Serveur Bind9) :

  - Le client interroge le serveur DNS local pour résoudre `www.cfitech-it.com`.
  - Le serveur vérifie la signature DNSSEC avant de répondre.

- **Requête HTTPS** (Client → Serveur Apache2) :
  - Le client accède à `https://cfitech-it.com`.
  - Apache2 fournit le certificat SSL pour établir une connexion chiffrée.

#### Partie 1 : Configuration du Serveur DNS (Bind9 + DNSSEC)

- Mise à Jour du Système

```sh
sudo apt update && sudo apt upgrade -y
```

- Installation de Bind9

```sh
sudo apt install bind9 bind9utils bind9-doc -y
sudo systemctl enable bind9
sudo systemctl start bind9
```

- Ouvrez le port DNS (53) dans le pare-feu

```sh
sudo ufw allow 53
sudo ufw reload
```

- Configurez une adresse IP statique pour le serveur primaire

```sh
sudo nano /etc/netplan/01-netcfg.yaml
```

- Ajoutez la configuration suivante (remplacez enp0s3 par votre interface réseau)

```sh
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: false 
      addresses: [172.28.0.2/16]
      routes:
        - to: default
          via: 172.28.0.1
      nameservers:
        addresses: [172.28.0.2]
```

- Appliquez la configuration

```sh
sudo netplan apply
```

- Configuration de Bind9
  - Éditez le fichier /etc/bind/named.conf.options

```sh
sudo nano /etc/bind/named.conf.options
```

- Ajoutez ou modifiez les options suivantes pour sécuriser le serveur

```sh
options {
    directory "/var/cache/bind";

    forwarders { 8.8.8.8; 8.8.4.4; };

    dnssec-validation auto;

    listen-on { 172.28.0.2; };            # Adresse IP du serveur primaire.
    listen-on-v6 { none; };                # Désactiver IPv6 si non utilisé.
    allow-query { 172.28.0.0/16; };       # Limiter les requêtes au réseau local.
    allow-recursion { 172.28.0.0/16; };   # Limiter la récursion aux clients internes.
};
```

- Redémarrez Bind9 pour appliquer les modifications

```sh
sudo systemctl restart bind9
```

- Ajouter des Zones Directes et Inversées
  -- Ajoutez vos zones dans le fichier /etc/bind/named.conf.local

```sh
sudo nano /etc/bind/named.conf.local
```

- Ajoutez ce contenu

```sh
zone "cfitech-it.com" {
    type master;
    file "/etc/bind/db.cfitech-it.com";
    allow-transfer { 172.28.0.3; };     # Autorise le transfert vers le serveur secondaire.
    also-notify { 172.28.0.3; };        # Notifie le serveur secondaire des mises à jour.
};

zone "1.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.rev.cfitech-it.com";
};
```

- Créer un Fichier pour la Zone Directe

```sh
sudo cp /etc/bind/db.local /etc/bind/db.cfitech-it.com
```

```sh
sudo nano /etc/bind/db.cfitech-it.com
```

- Contenu du fichier

```sh
$TTL    604800
@       IN      SOA     ns.cfitech-it.com. admin.cfitech-it.com. (
                        2025040200 ; Serial (à incrémenter lors des modifications)
                        10h        ; Refresh
                        15m        ; Retry
                        48h        ; Expire
                        604800 )   ; Negative Cache TTL

@       IN      NS      ns.cfitech-it.com.
@       IN      NS      ns2.cfitech-it.com.
@       IN      A       172.28.0.2

ns      IN      A       172.28.0.2   ; Serveur primaire.
ns2     IN      A       172.28.0.3   ; Serveur secondaire.
www     IN      CNAME   ns            ; Alias vers ns.
router  IN      A       172.28.0.1   ; Routeur local.
```

- Créer un Fichier pour la Zone Inversée

```sh
sudo cp /etc/bind/db.local /etc/bind/db.rev.cfitech-it.com
```

```sh
sudo nano /etc/bind/db.rev.cfitech-it.com
```

- Contenu du fichier

```sh
$TTL    604800
@       IN      SOA     ns.cfitech-it.com. admin.cfitech-it.com. (
                        2025040200 ; Serial (à incrémenter)
                        10h        ; Refresh
                        15m        ; Retry
                        48h        ; Expire
                        604800 )   ; Negative Cache TTL

@       IN      NS      ns.cfitech-it.com.
@       IN      NS      ns2.cfitech-it.com.

2       IN      PTR     ns.cfitech-it.com.
3       IN      PTR     ns2.cfitech-it.com.
```

- Avant de redémarrer Bind9, vérifiez vos fichiers de configuration

```sh
# Vérifie la syntaxe générale.
sudo named-checkconf

# Vérifie la zone directe.
sudo named-checkzone cfitech-it.com /etc/bind/db.cfitech-it.com

# Vérifie la zone inversée.
sudo named-checkzone 1.168.192.in-addr.arpa /etc/bind/db.rev.cfitech-it.com
```

- Redémarrez Bind9 après vérification

```sh
sudo systemctl restart bind9 && sudo systemctl status bind9
```

#### Activer DNSSEC pour Sécuriser vos Zones DNS

- Générer les Clés DNSSEC
  - Générez une clé ZSK (Zone Signing Key) et une clé KSK (Key Signing Key) pour signer vos zones.

```sh
cd /etc/bind/

# Génération des clés
sudo dnssec-keygen -a RSASHA256 -b 2048 -n ZONE cfitech-it.com

# Signature de la zone
sudo dnssec-keygen -f KSK -a RSASHA256 -b 4096 -n ZONE cfitech-it.com
```

#### Signer la Zone avec DNSSEC

- Ajoutez les clés publiques dans votre fichier de zone /etc/bind/db.cfitech-it.com

```sh
;
; BIND data file for cfitech-it.com
;
$TTL    604800
@       IN      SOA     ns.cfitech-it.com. admin.cfitech-it.com. (
                        2025040200 ; Serial (à incrémenter lors des modifications)
                        10h        ; Refresh
                        15m        ; Retry
                        48h        ; Expire
                        604800 )   ; Negative Cache TTL

@       IN      NS      ns.cfitech-it.com.
@       IN      NS      ns2.cfitech-it.com.
@       IN      A       172.28.0.2

ns      IN      A       172.28.0.2   ; Serveur primaire.
ns2     IN      A       172.28.0.3   ; Serveur secondaire.
www     IN      CNAME   ns            ; Alias vers ns.
router  IN      A       172.28.0.1   ; Routeur local.

$INCLUDE /etc/bind/Kcfitech-it.com.+008+13234.key
$INCLUDE /etc/bind/Kcfitech-it.com.+008+42967.key
```

- Signez la zone avec cette commande

```sh
sudo dnssec-signzone -A -o cfitech-it.com -t /etc/bind/db.cfitech-it.com
```

- Cela génère un fichier signé /etc/bind/db.cfitech-it.com.signed.
  - Modifiez `/etc/bind/named.conf.local` pour utiliser le fichier signé

```sh
zone "cfitech-it.com" {
    type master;
    file "/etc/bind/db.cfitech-it.com.signed";
    allow-transfer { 172.28.0.3; };           # Autorise le transfert vers le serveur secondaire.
    also-notify { 172.28.0.3; };              # Notifie le serveur secondaire des mises à jour.
};

zone "1.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.rev.cfitech-it.com";
};
```

- Redémarrez Bind9 après ces modifications.

```sh
sudo systemctl restart bind9
```

#### Partie 2 : Configuration d'Apache2 avec SSL

- Installez Apache2 et Activez SSL

```sh
sudo apt install apache2 -y
sudo a2enmod ssl
```

- Créez un certificat auto-signé pour HTTPS

```sh
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/apache-selfsigned.key \
    -out /etc/ssl/certs/apache-selfsigned.crt \
    -subj "/C=FR/ST=Paris/L=Paris/O=cfitech-it/OU=IT/CN=cfitech-it.com"
```

#### Remarque:

- `-x509` : Génère un certificat auto-signé.

- `-nodes` : Ne crypte pas la clé privée.

- `-days 365` : Définit la validité du certificat à 365 jours.

- `-newkey rsa:2048` : Crée une nouvelle clé RSA de 2048 bits.

- `-subj` : Définit les informations du certificat (remplacez par vos données).

- Assurez-vous que les permissions des fichiers sont correctes

```sh
sudo chmod 600 /etc/ssl/private/apache-selfsigned.key
sudo chmod 644 /etc/ssl/certs/apache-selfsigned.crt
sudo chown root:root /etc/ssl/private/apache-selfsigned.key /etc/ssl/certs/apache-selfsigned.crt
```

- Configurez le Virtual Host pour HTTPS
  - Créez un fichier de configuration pour votre site

```sh
sudo nano /etc/apache2/sites-available/cfitech-it.com.conf
```

- Ajoutez la configuration suivante

```sh
 # Redirection HTTP → HTTPS
<VirtualHost *:80>
    ServerName cfitech-it.com
    Redirect permanent / https://cfitech-it.com/
</VirtualHost>

# Configuration du Virtual Host HTTPS
<VirtualHost *:443>
    SSLEngine on

    SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
    SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key

    ServerAdmin admin@cfitech-it.com
    ServerName cfitech-it.com
    ServerAlias www.cfitech-it.com

    DocumentRoot /var/www/cfitech-it.com

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined

    <Directory /var/www/cfitech-it.com>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

- Créez le dossier racine pour votre site et ajoutez un fichier index.html de test

```sh
sudo mkdir -p /var/www/cfitech-it.com
echo "<h1>Si tu en as vraiment la volonté, tu peux y arriver</h1>" | sudo tee /var/www/cfitech-it.com/index.html > /dev/null
```

- Activez le fichier de configuration de votre site et désactivez le site par défaut d'Apache

```sh
sudo a2ensite cfitech-it.com.conf
sudo a2dissite 000-default.conf
sudo apache2ctl configtest
sudo systemctl restart apache2
```

- Ouvrez les ports HTTP (80) et HTTPS (443) dans le pare-feu

```sh
sudo ufw allow 'Apache Full'
sudo ufw reload
```

- **Note**: Pour que votre serveur DNS pointe correctement vers votre serveur Web, assurez-vous d'ajouter les enregistrements DNS appropriés dans Bind.

```sh
;
; BIND data file for cfitech-it.com
;
$TTL    604800
@       IN      SOA     ns.cfitech-it.com. admin.cfitech-it.com. (
                        2025021401 ; Serial (à incrémenter lors des modifications)
                        10h        ; Refresh
                        15m        ; Retry
                        48h        ; Expire
                        604800 )   ; Negative Cache TTL

@       IN      NS      ns.cfitech-it.com.
@       IN      NS      ns2.cfitech-it.com.
@       IN      A       172.28.0.2

ns      IN      A       172.28.0.2   ; Serveur primaire.
ns2     IN      A       172.28.0.3   ; Serveur secondaire.
www     IN      CNAME   @             ; Alias pour www.cfitech-it.com.
router  IN      A       172.28.0.1   ; Routeur local.

$INCLUDE /etc/bind/Kcfitech-it.com.+008+13234.key
$INCLUDE /etc/bind/Kcfitech-it.com.+008+42967.key
```

- Après avoir modifié ce fichier, vérifiez la syntaxe et redémarrez Bind9
  - Vérifiez la syntaxe des fichiers de zone.

```sh
sudo named-checkzone cfitech-it.com /etc/bind/db.cfitech-it.com
```

- Redémarrez Bind9.

```sh
sudo systemctl restart bind9
```

- Testez la résolution DNS directe avec DNSSEC

```sh
dig +dnssec www.cfitech-it.com @172.28.0.2
```

- Testez la résolution inversée avec DNSSEC

```sh
dig -x 172.28.0.2 +dnssec @172.28.0.2
```

- Ouvrez un navigateur et Accédez à `https://cfitech-it.com` (un avertissement peut apparaître avec un certificat auto-signé).
