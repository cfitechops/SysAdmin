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
sudo apt update
sudo apt install isc-dhcp-server iptables-persistent vim -y
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
        - 192.168.10.2/24
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
      routes:
        - to: default
          via: 192.168.10.254
```

```sh
sudo netplan apply
```

#### Définition de l'interface DHCP

```sh
sudo cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.bkp
echo 'INTERFACESv4="enp0s3"' | sudo tee /etc/default/isc-dhcp-server
```

#### Configuration du serveur DHCP

- Configuration principale

```sh
sudo cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bkp
sudo vim /etc/dhcp/dhcpd.conf

# Nettoyage des fichiers de configuration
:g/^\$*#/d
```

- Ajoutez les paramètres suivants

```sh
# Paramètres globaux
option domain-name "example.local";
option domain-name-servers 8.8.8.8, 1.1.1.1;
default-lease-time 600;
max-lease-time 7200;
ddns-update-style none;
authoritative;

# Sous-réseau principal
subnet 192.168.10.0 netmask 255.255.255.0 {
    range 192.168.10.50 192.168.10.200;
    option routers 192.168.10.254;
    option subnet-mask 255.255.255.0;
    option domain-name-servers 8.8.8.8, 1.1.1.1;
}

# Réservation statique (exemple : imprimante)
host reserved-client {
    hardware ethernet 08:00:27:bd:22:0c;
    fixed-address 192.168.10.50;
}
```

- **Explications** :

  - `range` → Plage d’IP attribuées automatiquement
  - `host reserved-client` → IP fixe pour un appareil spécifique (ex: serveur, imprimante)
  - `default-lease-time` → Durée avant renouvellement du bail

#### Démarrage et vérification

```sh
sudo dhcpd -t                             # Vérification syntaxique
sudo systemctl restart isc-dhcp-server    # Redémarrage du service
sudo systemctl enable isc-dhcp-server     # Activation au démarrage
sudo systemctl status isc-dhcp-server     # Vérification du statut
```

#### Activation du NAT pour l’accès Internet

```sh
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

- Configurer les règles NAT (remplacez enp0s8 par l’interface vers Internet) :

```sh
sudo iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE
sudo iptables -A FORWARD -i enp0s3 -o enp0s8 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i enp0s8 -o enp0s3 -j ACCEPT
sudo iptables-save | sudo tee /etc/iptables/rules.v4
```

#### Vérification des baux et surveillance

```sh
sudo dhcp-lease-list                          # Liste des baux attribués
tail -f /var/log/syslog | grep dhcpd          # Logs en temps réel
journalctl -xeu isc-dhcp-server.service       # Logs système détaillés
```

#### Dépannage côté client (Linux)

```sh
sudo dhclient -v        # Demande d'adresse IP en mode verbeux
ip a                    # Vérification de l'adresse reçue
```