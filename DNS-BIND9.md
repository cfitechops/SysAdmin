#### Installation des paquets nécessaires

- Sur chaque serveur DNS (primaire et secondaire), installez BIND9 et configurez les services nécessaires

```sh
sudo apt update && sudo apt install bind9 bind9utils bind9-doc iptables-persistent -y
sudo ufw allow bind9
```

#### Configuration de l'interface réseau

- Attribuez une adresse IP statique à chaque serveur DNS. Voici un exemple pour le serveur primaire :

```sh
sudo nano /etc/netplan/cfg-static-ip.yaml
```

- Ajoutez la configuration suivante pour le serveur primaire (192.168.10.2) :

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

- Pour le serveur secondaire (192.168.10.3), modifiez l'adresse IP en conséquence.
- Appliquez les modifications

```sh
sudo netplan apply
```

#### Configuration du serveur DNS primaire

- Configurer les options globales
  - Modifiez /etc/bind/named.conf.options pour définir les forwarders et autoriser les requêtes

```sh
sudo nano /etc/bind/named.conf.options
```

- Ajoutez ou modifiez comme suit

```sh
options {
    directory "/var/cache/bind";

    forwarders {
        8.8.8.8;
        8.8.4.4;
    };

    dnssec-validation auto;

    listen-on {
            any;
            # 192.168.10.0/24;
    };

    listen-on-v6 { any; };

    allow-query {
            any; # Autorise toutes les requêtes si nécessaire.
            
            #192.168.10.47; Spécifier des équipes par exemple qui serait mon équipe host.
    }; 
};
```

- Redémarrez BIND9

```sh
sudo systemctl restart bind9
```

#### Configurer la zone principale

- Modifiez /etc/bind/named.conf.local pour ajouter la zone principale

```sh
sudo nano /etc/bind/named.conf.local
```

- Ajoutez

```sh
zone "cfitech-it.com" {
    type master;
    file "/etc/bind/db.cfitech-it.com";
    allow-transfer { 192.168.10.3; }; # Autorise le transfert vers le serveur secondaire
    also-notify { 192.168.10.3; };   # Notifie le serveur secondaire des changements
};

zone "1.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.1.168.192.in-addr.arpa";
};
```

#### Créer les fichiers de zones

- Zone directe (cfitech-it.com)
  - Créez le fichier de zone principale

```sh
sudo cp /etc/bind/db.local /etc/bind/db.cfitech-it.com

sudo nano /etc/bind/db.cfitech-it.com
```

- Modifiez comme suit

```sh
$TTL    604800
@       IN      SOA     ns.cfitech-it.com. admin.cfitech-it.com. (
                        2025040200 ; Serial (à incrémenter à chaque modification)
                        10h        ; Refresh interval
                        15m        ; Retry interval
                        48h        ; Expire interval
                        604800     ; Negative Cache TTL
)

@       IN      NS      ns.cfitech-it.com.
@       IN      NS      ns2.cfitech-it.com.
ns      IN      A       192.168.10.2 # Serveur primaire DNS
ns2     IN      A       192.168.10.3 # Serveur secondaire DNS

router  IN      A       192.168.10.1 # Routeur par défaut interne (facultatif)
www     IN      CNAME   router      # Alias pour www.cfitech-it.com -> router.
```

#### Zone inverse (1.168.192.in-addr.arpa)

- Créez le fichier de zone inverse :

```sh
sudo cp /etc/bind/db.local /etc/bind/db.1.168.192.in-addr.arpa
sudo nano /etc/bind/db.1.168.192.in-addr.arpa
```

- Modifiez comme suit

```sh
$TTL    604800

@       IN      SOA     ns.cfitech-it.com. admin.cfitech-it.com. (
                        2025040200 ; Serial (à incrémenter à chaque modification)
                        10h        ; Refresh interval
                        15m        ; Retry interval
                        48h        ; Expire interval
                        604800     ; Negative Cache TTL
)

@       IN      NS      ns.cfitech-it.com.
@       IN      NS      ns2.cfitech-it.com.

2       IN      PTR     ns.cfitech-it.com.
3       IN      PTR     ns2.cfitech-it.com.
1       IN      PTR     router.cfitech-it.com.
```

- Vérifiez la syntaxe des fichiers de zones

```sh
sudo named-checkzone cfitech-it.com /etc/bind/db.cfitech-it.com
sudo named-checkzone "1.168.192.in-addr.arpa" /etc/bind/db.1.168.192.in-addr.arpa
```

- Redémarrez BIND9

```sh
sudo systemctl restart bind9 && sudo systemctl status bind9
```

#### Configuration du serveur DNS secondaire

- Sur le serveur secondaire, configurez /etc/bind/named.conf.local pour recevoir les zones du primaire

```sh
sudo nano /etc/bind/named.conf.local
```

- Ajoutez

```sh
zone "cfitech-it.com" {
    type slave;
    file "/var/cache/bind/slave.db.cfitech-it.com";
    masters { 192.168.10.2; }; # Serveur primaire DNS
};

zone "1.168.192.in-addr.arpa" {
    type slave;
    file "/var/cache/bind/slave.db.reverse";
    masters { 192.168.10.2; };
};
```

- Redémarrez BIND9 sur le secondaire

```sh
sudo systemctl restart bind9 && sudo systemctl status bind9
```

#### Tests et Vérifications

- Test de la résolution directe (DNS primaire et secondaire)
  - Depuis un client ou un autre serveur, exécutez

```sh
nslookup www.cfitech-it.com 192.168.10.2 # x = IP du primaire ou secondaire.
dig @192.168.10.2 www.cfitech-it.com       # Vérifie les détails de la résolution.
ping www.cfitech-it.com                 # Vérifie la connectivité.
```

#### Test de la résolution inverse (DNS primaire)

```sh
nslookup 192.168.10.2                     # Résolution IP -> Nom.
dig -x 192.168.10.2                      # Vérifie les détails de la résolution inverse.
```

#### Sécurité et Haute Disponibilité

- Sécurisation avec iptables
  - Autorisez uniquement le trafic DNS sur le port 53 depuis des sources autorisées

```sh
sudo ufw allow from any to any port 53 proto udp comment "Allow DNS UDP"
sudo ufw allow from any to any port 53 proto tcp comment "Allow DNS TCP"
sudo ufw enable && sudo ufw status verbose
```

#### Activer DNSSEC (DNS Security Extensions)

- Ajoutez dans /etc/bind/named.conf.options pour signer vos zones DNS

```sh
dnssec-enable yes;
dnssec-validation auto;
```

- Générez des clés DNSSEC et signez vos zones

#### Surveillance et Maintenance

- Utilisez des outils comme **Zabbix** ou **Prometheus** pour surveiller vos serveurs DNS en temps réel
- Automatisez l'incrémentation du numéro de série dans vos fichiers de zone avec des scripts

#### Note:

- Avec cette configuration adaptée, vous obtenez une infrastructure DNS professionnelle robuste, redondante, sécurisée, et évolutive, prête à être déployée.
