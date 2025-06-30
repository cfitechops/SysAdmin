#### Installation des paquets nécessaires

```sh
sudo apt update
sudo apt install nginx -y
```

#### Configuration du Proxy NGINX (debianprox.local)

```sh
sudo nano /etc/nginx/sites-available/debianprox.conf
```

```sh
server {
    listen 80;
    server_name debianprox.local www.debianprox.local;

    location / {
        proxy_pass http://192.168.129.XXX;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

#### Activer le site et redémarrer NGINX

```sh
sudo ln -s /etc/nginx/sites-available/debianprox.conf /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl restart nginx
```

## Configuration DNS BIND9

#### Éditer la zone DNS

```sh
sudo nano /etc/bind/zones/db.diarabaka.local
```

```sh
debianprox.local  IN    A    192.168.129.172
```

#### Redémarrage DNS

```sh
sudo systemctl restart bind9
sudo systemctl status bind9
```

#### Activation du forwarding IPv4 (optionnel)

```sh
sudo sysctl -w net.ipv4.ip_forward=1
sudo nano /etc/sysctl.conf
```

- Ajouter ou décommenter la ligne

```sh
net.ipv4.ip_forward=1
```

#### Création du site Web sécurisé (asir.diarabaka.local)

```sh
sudo mkdir -p /var/www/asir.diarabaka.local/html
sudo chown -R $USER:$USER /var/www/asir.diarabaka.local
sudo chmod -R 755 /var/www/asir.diarabaka.local
```

#### Créer la page d’accueil

```sh
sudo nano /var/www/asir.diarabaka.local/html/index.html
```

```sh
<h1>Bienvenue sur ASIR HTTPS</h1>
```

#### Configurer le site HTTP

```sh
sudo nano /etc/nginx/sites-available/asir.diarabaka.local
```

```sh
server {
    listen 80;
    listen [::]:80;

    root /var/www/asir.diarabaka.local/html;
    index index.html index.htm index.nginx-debian.html;

    server_name asir.diarabaka.local www.asir.diarabaka.local;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

#### Activer le site

```sh
sudo ln -s /etc/nginx/sites-available/asir.diarabaka.local /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl restart nginx
```

## Activer le HTTPS avec certificat auto-signé

#### Créer le dossier SSL

```sh
sudo mkdir /etc/nginx/ssl-certs/
```

#### Générer les certificats

```sh
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/nginx/ssl-certs/nginx.key \
-out /etc/nginx/ssl-certs/nginx.crt
```

#### Modifier la configuration NGINX pour le HTTPS

```sh
sudo nano /etc/nginx/sites-available/asir.diarabaka.local
```

```sh
server {
    listen 80;
    listen [::]:80;

    server_name asir.diarabaka.local www.asir.diarabaka.local;

    return 301 https://asir.diarabaka.local;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;

    ssl on;
    ssl_certificate /etc/nginx/ssl-certs/nginx.crt;
    ssl_trusted_certificate /etc/nginx/ssl-certs/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl-certs/nginx.key;

    root /var/www/asir.diarabaka.local/html;
    index index.html index.htm index.nginx-debian.html;

    server_name asir.diarabaka.local www.asir.diarabaka.local;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

#### Redémarrer NGINX

```sh
sudo systemctl reload nginx
```

#### Vérifications

```sh
dig @192.168.129.172 prox.diarabaka.local
dig -x 192.168.129.172 @192.168.129.172

curl http://debianprox.local
curl -k https://asir.diarabaka.local  # Le -k ignore l'avertissement SSL auto-signé
```