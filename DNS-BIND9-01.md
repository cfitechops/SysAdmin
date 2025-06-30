# Serveur DNS avec BIND9 sur Ubuntu Server

## Configuration IP statique avec Netplan

#### Édition du fichier de configuration

```sh
sudo nano /etc/netplan/00-installer-config.yaml
```

- contenu

```sh
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: false
    enp0s8:
      addresses: [192.168.129.172/24]
      nameservers:
        addresses: [1.1.1.1, 8.8.8.8]
```

#### Application de la configuration

```sh
sudo netplan apply
```

#### Installation de BIND9 et activation du pare-feu

```sh
sudo apt update
sudo apt install bind9 bind9-utils -y
```

#### Activation et autorisation UFW

```sh
sudo ufw enable
sudo ufw allow bind9
sudo ufw status
```

#### Démarrage de BIND9

```sh
sudo systemctl start bind9
sudo systemctl status bind9
```

#### Configuration de BIND : named.conf.options

```sh
sudo nano /etc/bind/named.conf.options
```

```sh
options {
    directory "/var/cache/bind";
    listen-on { any; };
    allow-query { localhost; 192.168.129.0/24; };
    forwarders {
        8.8.8.8;
    };
    dnssec-validation no;
};
```

#### Forcer l'utilisation d'IPv4

```sh
sudo nano /etc/default/named
```

```sh
OPTIONS="-u bind -4"
```

```sh
sudo named-checkconf
sudo systemctl restart bind9
```

#### Déclaration des zones DNS

```sh
sudo nano /etc/bind/named.conf.local
```

- Contenu

```sh
zone "diarabaka.local" IN {
    type master;
    file "/etc/bind/zones/db.diarabaka.local";
};

zone "129.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.129.168.192";
};
```

#### Création des fichiers de zones

```sh
sudo mkdir -p /etc/bind/zones
sudo cp /etc/bind/db.local /etc/bind/zones/db.diarabaka.local
```

#### Zone directe : db.diarabaka.local

```sh
sudo nano /etc/bind/zones/db.diarabaka.local
```

```sh
$TTL 604800
@       IN  SOA dns01.diarabaka.local. root.diarabaka.local. (
                2         ; Serial
           604800         ; Refresh
            86400         ; Retry
          2419200         ; Expire
           604800 )       ; Negative Cache TTL
;
        IN  NS  dns01.diarabaka.local.
dns01   IN  A   192.168.129.172
server  IN  CNAME dns01
```

#### Zone inverse : db.129.168.192

```sh
sudo cp /etc/bind/zones/db.diarabaka.local /etc/bind/zones/db.129.168.192
sudo nano /etc/bind/zones/db.129.168.192
```

```sh
$TTL 604800
@       IN  SOA dns01.diarabaka.local. root.diarabaka.local. (
                2         ; Serial
           604800         ; Refresh
            86400         ; Retry
          2419200         ; Expire
           604800 )       ; Negative Cache TTL
;
        IN  NS  dns01.diarabaka.local.
172     IN  PTR dns01.diarabaka.local.
```

#### Vérification de la configuration

```sh
sudo named-checkconf /etc/bind/named.conf.local
sudo named-checkzone diarabaka.local /etc/bind/zones/db.diarabaka.local
sudo named-checkzone 129.168.192.in-addr.arpa /etc/bind/zones/db.129.168.192
```

#### Redémarrage de BIND9

```sh
sudo systemctl restart bind9
sudo systemctl status bind9
```

#### Configuration DNS locale (résolution)

```sh
sudo nano /etc/resolv.conf
```

- Exemple

```sh
nameserver 192.168.129.172
nameserver 127.0.0.53
options edns0 trust-ad
search diarabaka.local
```

#### Pour éviter que resolv.conf soit écrasé

```sh
sudo cp /etc/resolv.conf /etc/resolv.conf.back
sudo chattr +i /etc/resolv.conf.back
sudo rm -f /etc/resolv.conf
sudo cp /etc/resolv.conf.back /etc/resolv.conf
```

#### Tests de résolution DNS

```sh
host dns01.diarabaka.local
ping dns01.diarabaka.local
host dns01
host 192.168.129.172
```

#### Sécurisation

- Vérifier les permissions des fichiers

```sh
sudo chown -R bind:bind /etc/bind/zones
```