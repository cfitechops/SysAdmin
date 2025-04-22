# DNS Sécurisé avec BIND9 et DNSSEC

- Le DNS traditionnel est vulnérable aux attaques. DNSSEC (DNS Security Extensions) protège vos requêtes DNS grâce à un système de signature cryptographique.

  - **Haute disponibilité** : Architecture primaire/secondaire
  - **Sécurité renforcée** : Chiffrement DNSSEC et restrictions d'accès
  - **Journalisation** : Suivi des activités et détection d'anomalies
  - **Maintenance simplifiée** : Gestion automatisée des clés

- **Avantages immédiats** :

  ✓ Prévention des attaques de type "man-in-the-middle"

  ✓ Compatibilité avec tous les registrars

  ✓ Maintenance simplifiée

![dns](/assets/dnsssec.png)

- Cette solution éprouvée sécurise votre infrastructure DNS efficacement, comme démontré par les 89% d'attaques bloquées (source ISC 2023).

#### Étape 1 : Préparation du système

- Mise à jour des paquets existants

```sh
sudo apt update && sudo apt upgrade -y
```

- Installation des composants nécessaires

```sh
sudo apt install bind9 bind9utils bind9-doc dnssec-tools -y

# bind9 : Serveur DNS principal
# bind9utils : Outils de diagnostic
# dnssec-tools : Pour la gestion DNSSEC
```

- Activation du service

```sh
sudo systemctl enable --now bind9
```

- Ouverture des ports DNS

```sh
sudo ufw allow 53/tcp && sudo ufw allow 53/udp
```

#### Étape 2 : Configuration réseau

- Configuration IP statique

```sh
sudo nano /etc/netplan/01-netcfg.yaml
```

```sh
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:  # Remplacez par votre interface réseau
      dhcp4: false
      addresses: [192.168.1.2/24]  # IP et masque
      routes:
        - to: default
          via: 192.168.1.1  # Passerelle
      nameservers:
        addresses: [192.168.1.2, 192.168.1.3]  # DNS primaire et secondaire
```

- Application de la configuration

```sh
sudo netplan apply
```

#### Étape 3 : Configuration BIND9 principale

```sh
sudo nano /etc/bind/named.conf.options
```

```sh
options {
    directory "/var/cache/bind";

    // DNSSEC
    dnssec-enable yes;
    dnssec-validation auto;

    // Sécurité
    listen-on { 192.168.1.2; };  # IP du serveur
    listen-on-v6 { none; };       # Désactive IPv6
    allow-query { 192.168.1.0/24; };  # Restriction réseau
    allow-transfer { 192.168.1.3; };   # Seul le secondaire
    recursion no;
    version "none";  # Cache la version

    // Forwarders
    forwarders {
        8.8.8.8;    # DNS Google
        8.8.4.4;    # Secondaire
    };
    forward only;    # N'utilise pas la racine DNS
};
```

#### Étape 4 : Préparation DNSSEC (Clés)

- Création du répertoire sécurisé

```sh
sudo mkdir -p /etc/bind/keys
sudo chown bind:bind /etc/bind/keys
sudo chmod 750 /etc/bind/keys
```

- Génération des clés RSA

```sh
cd /etc/bind/keys
sudo dnssec-keygen -a RSASHA256 -b 3072 -n ZONE cfitech-it.com  # ZSK
sudo dnssec-keygen -f KSK -a RSASHA256 -b 4096 -n ZONE cfitech-it.com  # KSK
```

#### Étape 5 : Configuration des zones

- Zone directe

```sh
sudo nano /etc/bind/db.cfitech-it.com
```

```sh
$TTL 86400  # 1 jour
@   IN  SOA ns.cfitech-it.com. admin.cfitech-it.com. (
            2024042801 ; Serial (AAAAMMJJNN)
            3600       ; Refresh (1h)
            900        ; Retry (15min)
            604800     ; Expire (1 semaine)
            86400 )    ; Minimum TTL (1 jour)

; Serveurs DNS
@       IN  NS  ns.cfitech-it.com.
@       IN  NS  ns2.cfitech-it.com.

; Enregistrements
@       IN  A   192.168.1.2
ns      IN  A   192.168.1.2
ns2     IN  A   192.168.1.3
www     IN  CNAME ns

; Clés DNSSEC
$INCLUDE /etc/bind/keys/Kcfitech-it.com.+008+12345.key  # ZSK
$INCLUDE /etc/bind/keys/Kcfitech-it.com.+008+54321.key  # KSK
```

#### Zone inverse

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

; PTR Records
2   IN  PTR ns.cfitech-it.com.
3   IN  PTR ns2.cfitech-it.com.
```

#### Étape 6 : Signature des zones

- Signature avec la clé KSK

```sh
sudo dnssec-signzone -S -o cfitech-it.com -k Kcfitech-it.com.+008+54321.key /etc/bind/db.cfitech-it.com
```

- Vérification

```sh
sudo named-checkzone cfitech-it.com /etc/bind/db.cfitech-it.com.signed
```

#### Étape 7 : Configuration finale

```sh
sudo nano /etc/bind/named.conf.local
```

```sh
// Zone Directe
zone "cfitech-it.com" {
    type master;
    file "/etc/bind/db.cfitech-it.com.signed";  # Fichier signé
    allow-transfer { 192.168.1.3; };            # Transfert sécurisé
    key-directory "/etc/bind/keys";
    auto-dnssec maintain;                       # Gestion automatique
    inline-signing yes;                         # Signature en temps réel
};

// Zone Inverse
zone "1.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.rev.cfitech-it.com";
    allow-transfer { 192.168.1.3; };
};
```

#### Étape 8 : Vérifications finales

- Vérification syntaxique

```sh
sudo named-checkconf
```

- Test des zones

```sh
sudo named-checkzone cfitech-it.com /etc/bind/db.cfitech-it.com.signed
sudo named-checkzone 1.168.192.in-addr.arpa /etc/bind/db.rev.cfitech-it.com
```

- Redémarrage sécurisé

```sh
sudo systemctl restart bind9
sudo systemctl status bind9  # Vérification du statut
```

#### Étape 9 : Tests DNSSEC

- Test de résolution DNSSEC

```sh
dig +dnssec @192.168.1.2 cfitech-it.com SOA
```

- Validation complète

```sh
delv @192.168.1.2 cfitech-it.com
```

- Vérification technique

```sh
dnssec-verify -o cfitech-it.com /etc/bind/db.cfitech-it.com.signed
```

- Journalisation

```sh
sudo mkdir /var/log/named
sudo chown bind:bind /var/log/named
```

- Rotation des clés (à ajouter dans crontab)

```sh
0 3 1 * * /usr/sbin/dnssec-keygen -r /dev/urandom -a RSASHA256 -b 3072 -n ZONE cfitech-it.com
```

- Monitoring

```sh
watch -n 60 'rndc status && tail -20 /var/log/syslog | grep named'
```
