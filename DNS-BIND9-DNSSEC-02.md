# DNS BIND9 DNSSEC

- Une infrastructure DNS sécurisée est essentielle pour garantir la disponibilité et l'intégrité des services réseau. Cette configuration complète intègre BIND9 avec DNSSEC pour :

  - **Haute disponibilité** : Architecture primaire/secondaire
  - **Sécurité renforcée** : Chiffrement DNSSEC et restrictions d'accès
  - **Journalisation** : Suivi des activités et détection d'anomalies
  - **Maintenance simplifiée** : Gestion automatisée des clés

#### Topologie Globale

![dns](/assets/dnssec01.png)

#### Flux DNSSEC

![dns](/assets/dnssec02.png)

#### Hiérarchie des Clés DNSSEC

![dns](/assets/dnssec03.png)

#### PRÉPARATION DU SYSTÈME

```sh
sudo apt update && sudo apt upgrade -y
sudo apt install bind9 bind9utils bind9-doc dnssec-tools -y
sudo systemctl enable --now bind9
sudo ufw allow 53/tcp && sudo ufw allow 53/udp
```

#### CONFIGURATION RÉSEAU

```sh
sudo nano /etc/netplan/01-netcfg.yaml
```

```sh
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: false
      addresses: [192.168.1.2/24]
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses: [192.168.1.2, 192.168.1.3]
```

```sh
sudo netplan apply
```

#### CONFIGURATION BIND9 PRINCIPALE

```sh
sudo nano /etc/bind/named.conf.options
```

```sh
options {
    directory "/var/cache/bind";
    dnssec-enable yes;
    dnssec-validation auto;
    listen-on { 192.168.1.2; };
    listen-on-v6 { none; };
    allow-query { 192.168.1.0/24; };
    allow-transfer { 192.168.1.3; };
    recursion no;
    version "none";

    forwarders {
        8.8.8.8;
        8.8.4.4;
    };
};
```

#### PRÉPARATION DNSSEC (CLÉS)

```sh
sudo mkdir -p /etc/bind/keys
sudo chown bind:bind /etc/bind/keys

cd /etc/bind/keys

# Génération des clés (adaptez l'algorithme si nécessaire)
sudo dnssec-keygen -a RSASHA256 -b 3072 -n ZONE cfitech-it.com
sudo dnssec-keygen -f KSK -a RSASHA256 -b 4096 -n ZONE cfitech-it.com
```

#### CONFIGURATION DES ZONES

- Fichier de zone directe

```sh
sudo nano /etc/bind/db.cfitech-it.com
```

```sh
$TTL 86400
@   IN  SOA ns.cfitech-it.com. admin.cfitech-it.com. (
            2024042801 ; Serial
            3600       ; Refresh
            900        ; Retry
            604800     ; Expire
            86400 )    ; Minimum TTL

@       IN  NS  ns.cfitech-it.com.
@       IN  NS  ns2.cfitech-it.com.
@       IN  A   192.168.1.2
ns      IN  A   192.168.1.2
ns2     IN  A   192.168.1.3
www     IN  CNAME ns

$INCLUDE /etc/bind/keys/Kcfitech-it.com.+013+12345.key
$INCLUDE /etc/bind/keys/Kcfitech-it.com.+013+54321.key
```

#### Fichier de zone inverse

```sh
sudo nano /etc/bind/db.rev.cfitech-it.com
```

```sh
$TTL 86400
@   IN  SOA ns.cfitech-it.com. admin.cfitech-it.com. (
            2024042801 ; Serial
            3600       ; Refresh
            900        ; Retry
            604800     ; Expire
            86400 )    ; Minimum TTL

@   IN  NS  ns.cfitech-it.com.
@   IN  NS  ns2.cfitech-it.com.

2   IN  PTR ns.cfitech-it.com.
3   IN  PTR ns2.cfitech-it.com.
```

#### SIGNATURE DES ZONES

```sh
sudo dnssec-signzone -S -z -o cfitech-it.com -k Kcfitech-it.com.+013+54321.key /etc/bind/db.cfitech-it.com
```

#### CONFIGURATION FINALE

```sh
sudo nano /etc/bind/named.conf.local
```

```sh
zone "cfitech-it.com" {
    type master;
    file "/etc/bind/db.cfitech-it.com.signed";
    allow-transfer { 192.168.1.3; };
    key-directory "/etc/bind/keys";
    auto-dnssec maintain;
    inline-signing yes;
};

zone "1.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.rev.cfitech-it.com";
    allow-transfer { 192.168.1.3; };
};
```

#### VÉRIFICATIONS

```sh
sudo named-checkconf
sudo named-checkzone cfitech-it.com /etc/bind/db.cfitech-it.com.signed
sudo named-checkzone 1.168.192.in-addr.arpa /etc/bind/db.rev.cfitech-it.com
sudo systemctl restart bind9
```

#### TESTS DNSSEC

```sh
dig +dnssec @192.168.1.2 cfitech-it.com SOA
delv @192.168.1.2 cfitech-it.com
dnssec-verify -o cfitech-it.com /etc/bind/db.cfitech-it.com.signed
```
