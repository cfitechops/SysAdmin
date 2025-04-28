# Installation et Configuration d'un Serveur DHCP sous Linux

- Un serveur **DHCP (Dynamic Host Configuration Protocol)** est essentiel dans les réseaux professionnels pour attribuer automatiquement des adresses IP, des paramètres DNS et des passerelles aux appareils connectés.

- Ce projet fournit une procédure complète et il explique comment :

  - `Installer et configurer un serveur DHCP sous Linux (ISC-DHCP-Server)`
  - `Gérer les plages d’adresses IP dynamiques et statiques`
  - `Configurer le NAT pour permettre l’accès Internet aux clients`
  - `Surveiller et dépanner le service DHCP`

#### Schéma Réseau (Topologie)

```sh
+-------------------+       +-------------------+       +----------------------+
|   Client DHCP     |       |   Serveur DHCP    |       |   Routeur/Passerelle |
| (Obtenir IP auto) | <---> | (Linux - enp0s3)  | <---> |   (192.168.10.254)   |
+-------------------+       +-------------------+       +----------------------+
       ▲                                                         |
       |                                                         ▼
+-------------------+                                   +-------------------+
|   Internet        |                                   |   Autres Clients  |
|  (via NAT)        |                                   | (DHCP ou Static)  |
+-------------------+                                   +-------------------+
```

#### Composants clés

- `Serveur DHCP` (192.168.10.2) → Attribue les IP aux clients

- `Passerelle par défaut` (192.168.10.254) → Route le trafic vers Internet

- `Clients DHCP` → Reçoivent une IP automatiquement (192.168.10.50-200)

- `Réservation statique` → IP fixe pour certains appareils (ex: 192.168.10.50)

#### Installation des paquets nécessaires

```sh
sudo -i
sudo apt-get update
sudo apt-get install isc-dhcp-server vim iptables-persistent -y
```

- `isc-dhcp-server` → Service DHCP principal
- `iptables-persistent` → Sauvegarde des règles NAT après redémarrage

#### Configuration de l'interface réseau

- Configuration IP statique pour le serveur DHCP

```sh
sudo vi /etc/netplan/01-static-ip.yaml
```

```sh
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      addresses:
        - 192.168.10.2/24              # IP statique du serveur
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]  # DNS Google
      routes:
        - to: default
          via: 192.168.10.254          # Passerelle
```

```sh
sudo chmod 600 /etc/netplan/*.yaml
sudo netplan apply
```

#### Définition de l'interface DHCP

```sh
sudo cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.bkp

echo 'INTERFACESv4="enp0s3"' > /etc/default/isc-dhcp-server
```

#### Configuration du serveur DHCP

- Configuration principale

```sh
sudo cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bkp
```

```sh
sudo vi /etc/dhcp/dhcpd.conf

# Nettoyage des fichiers de configuration
:g/^\$*#/d
```

- Ajoutez les paramètres suivants

```sh
# Paramètres globaux du serveur DHCP
option domain-name "example.local";                # Nom de domaine interne (Active Directory si applicable)
option domain-name-servers 192.168.10.2, 8.8.8.8;  # DNS interne et externe (Google DNS en secours)
default-lease-time 600;                            # Durée par défaut du bail en secondes (10 minutes)
max-lease-time 7200;                               # Durée maximale du bail en secondes (2 heures)
ddns-update-style none;                            # Désactiver les mises à jour dynamiques DNS
authoritative;

subnet 192.168.10.0 netmask 255.255.255.0 {
    range 192.168.10.50 192.168.10.200;                # Plage d'adresses IP dynamiques attribuées aux clients DHCP
    option routers 192.168.10.1;                       # Adresse IP du serveur DHCP (passerelle par défaut)
    option subnet-mask 255.255.255.0;                  # Masque de sous-réseau
    option domain-name-servers 192.168.10.2, 8.8.8.8;  # DNS interne et externe
}

# Configuration d'une réservation statique pour un périphérique spécifique (par exemple, un serveur ou une imprimante)
host reserved-client {   # Réservation IP fixe
    hardware ethernet 08:00:27:bd:22:0c;   # Adresse MAC du périphérique réservé
    fixed-address 192.168.10.50;           # Adresse IP réservée au périphérique
}
```

- **Explications** :

  - `range` → Plage d’IP attribuées automatiquement
  - `host reserved-client` → IP fixe pour un appareil spécifique (ex: serveur, imprimante)
  - `default-lease-time` → Durée avant renouvellement du bail

#### Démarrage et vérification

```sh
dhcpd -t
systemctl restart isc-dhcp-server
systemctl enable isc-dhcp-server
systemctl status isc-dhcp-server
```

#### Activation du NAT pour Internet

```sh
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf  # Active le routage IP
sysctl -p

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE  # Masquage NAT
iptables -A FORWARD -i enp0s3 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o enp0s3 -j ACCEPT

iptables-save > /etc/iptables/rules.v4  # Sauvegarde des règles
```

#### Surveillance et maintenance

- Pour surveiller les baux DHCP:

```sh
systemctl status isc-dhcp-server      # Vérifie l’état du service

dhcp-lease-list                       # Liste les baux actifs
tail -f /var/log/syslog | grep dhcpd  # Logs en temps réel
```

- **Conclusion**:

  - Le serveur DHCP simplifie la gestion des adresses IP dans un réseau.
  - Les réservations statiques sont utiles pour les équipements critiques.
  - Le NAT permet aux clients d’accéder à Internet via le serveur.
