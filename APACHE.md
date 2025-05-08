# Serveur Web Apache avec HTTPS sur Ubuntu

- **Apache HTTP Server** est le serveur web open-source le plus répandu (40% des sites mondiaux en 2024).

- Dans ce guide, nous allons configurer un `serveur web Apache` sécurisé avec `HTTPS` :

  - 1 - Installation et configuration d'Apache
  - 2 - Virtual Host avec redirection HTTP→HTTPS
  - 3 - Certificat SSL auto-signé
  - 4 - Configuration du firewall
  - 5 - Solution sans DNS via le fichier hosts

#### Schéma d'architecture

```sh
[Client Internet]
       │
       ├──(HTTP)──▶ [Apache:80] ────┐
       │                            │ (Redirection)
       └──(HTTPS)─▶ [Apache:443] ◀──┘
                          │
                          ▼
           [/var/www/cfitech.it.local]
                 (Contenu web)
```

#### Fonctionnement clé :

- **Couche Réseau** : Apache écoute sur les ports 80 (HTTP) et 443 (HTTPS)
- **Moteur SSL** : Chiffrement via OpenSSL
- **Gestion des requêtes** :

  - Analyse des en-têtes HTTP
  - Routage vers le bon Virtual Host

#### Installation et Configuration d'Apache

- Mise à jour du Système

```sh
sudo apt update
sudo apt install apache2 -y
sudo systemctl enable apache2
sudo systemctl start apache2
sudo systemctl status apache2
```

- Configuration du Site Web
  - Création du Répertoire du Site

```sh
sudo mkdir -p /var/www/cfitech.it.local
```

- `/var/www/` : Dossier par défaut des sites web Apache.
- `-p `: Crée les sous-dossiers nécessaires.

- Modification des Permissions

```sh
sudo chown -R $USER:$USER /var/www/cfitech.it.local
sudo chmod -R 755 /var/www/cfitech.it.local
```

- `chown -R $USER:$USER` : Change le propriétaire vers l’utilisateur actuel.
- `chmod -R 755` : Donne les droits :

- Création d’une Page d’Accueil

```sh
sudo nano /var/www/cfitech.it.local/index.html
```

- Contenu

```sh
<h1>Si tu en as vraiment la volonté, tu peux y arriver</h1>
```

- Configuration du Virtual Host
  - Création du Fichier de Configuration

```sh
sudo nano /etc/apache2/sites-available/cfitech.it.local.conf
```

- Contenu

```sh
<VirtualHost *:80>
    ServerName cfitech.it.local
    ServerAlias www.cfitech.it.local YOUR_IP_ADDRESS
    Redirect permanent / https://cfitech.it.local/
</VirtualHost>

<VirtualHost *:443>
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
    SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key

    ServerAdmin cfitech@it.local
    ServerName cfitech.it.local
    ServerAlias www.cfitech.it.local YOUR_IP_ADDRESS
    DocumentRoot /var/www/cfitech.it.local

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined

    <Directory /var/www/cfitech.it.local>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

#### Explication :

- `<VirtualHost *:80>` : Écoute sur le port HTTP (80).
- `ServerName` : Nom de domaine principal.
- `ServerAlias` : Autres noms de domaine associés.
- `DocumentRoot` : Emplacement des fichiers du site.
- `ErrorLog` & `CustomLog` : Fichiers de logs.

- Activation du Site

```sh
sudo apache2ctl configtest  # Vérifie la syntaxe
sudo systemctl restart apache2
```

##### Configuration HTTPS (SSL/TLS)

- Génération d’un certificat auto-signé

```sh
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/apache-selfsigned.key \
    -out /etc/ssl/certs/apache-selfsigned.crt \
    -subj "/C=BE/ST=BXL/L=Koekelberg/O=Cfitech/OU=IT/CN=cfitech.it.local/emailAddress=your_email@gmail.com"
```

- Paramètres à entrer

- **Country Name** : `BE` (Belgique)
- **State or Province** : BXL (Bruxelles)
- **Locality** : `Koekelberg`
- **Organization** : `Cfitech`
- **Organizational Unit** : `IT`
- **Common Name** : `cfitech.it.local`
- **Email** : `YOUR EMAIL`

#### Activer les modules nécessaires

```sh
sudo a2enmod ssl rewrite
sudo a2ensite cfitech.it.local.conf
sudo a2dissite 000-default.conf
```

- Vérifier la configuration

```sh
sudo apache2ctl configtest
sudo systemctl restart apache2
```

#### Configuration du firewall

```sh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

#### Configuration du fichier hosts (à faire sur toutes les machines)

```sh
# Sur le serveur Linux
echo "YOUR_IP_ADDRESS cfitech.it.local www.cfitech.it.local" | sudo tee -a /etc/hosts

# Sur les clients Windows (à exécuter dans CMD en tant qu'admin):
echo YOUR_IP_ADDRESS cfitech.it.local www.cfitech.it.local >> C:\Windows\System32\drivers\etc\hosts
```

#### Vérification finale

```sh
# Tester depuis le serveur
curl -k https://cfitech.it.local
curl -k http://cfitech.it.local  # Doit rediriger vers HTTPS

# Vérifier les logs
tail -f /var/log/apache2/access.log
tail -f /var/log/apache2/error.log
```

#### Entrez dans votre navigateur

- **HTTP** : `http://YOUR_IP_ADDRESS/` → Doit rediriger vers HTTPS.
- **HTTPS** : `https://YOUR_IP_ADDRESS/` → Affiche la page avec un avertissement (certificat auto-signé).

#### Schéma Réseau Final

```sh
[Client]
   │
   ├─(HTTP)─> [Apache:80] → Redirige vers HTTPS
   │
   └─(HTTPS)─> [Apache:443] → Site sécurisé (SSL)
                  │
                  └─> /var/www/cfitech.it.local
```

- `Remarque`: Le serveur est maintenant opérationnel avec HTTPS forcé !
