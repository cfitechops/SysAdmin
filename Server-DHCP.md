#### Installation des paquets nécessaires

```sh
sudo -i
apt-get update
apt-get install isc-dhcp-server vim iptables-persistent -y
```
 
#### Configuration de l'interface pour le serveur DHCP

- Sauvegardez le fichier de configuration par défaut

```sh
cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.bkp
```

- Modifiez le fichier /etc/default/isc-dhcp-server

```sh
nano /etc/default/isc-dhcp-server
```

- Ajoutez ou modifiez la ligne suivante

```sh
INTERFACESv4="enp0s3"
```

- Assurez-vous que l'interface enp0s3 est configurée avec une adresse IP statique

#### Configuration d'une adresse IP statique pour le serveur

- Créez ou modifiez le fichier Netplan pour configurer une IP statique

```sh
cat > /etc/netplan/01-static-ip.yaml <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      addresses:
        - 192.168.10.2/24  # Adresse IP statique du serveur DHCP
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]  # Serveurs DNS publics ou internes
      routes:
        - to: default
          via: 192.168.10.254  # Passerelle par défaut (routeur)
EOF

chmod 600 /etc/netplan/*.yaml
netplan apply
```

#### Configuration du serveur DHCP

- Sauvegardez le fichier de configuration DHCP

```sh
cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bkp
```

- Modifiez le fichier /etc/dhcp/dhcpd.conf

```sh
vi /etc/dhcp/dhcpd.conf

# Nettoyage des fichiers de configuration
:g/^\$*#/d
```

- Ajoutez les paramètres suivants (adaptés à un contexte professionnel)

```sh
# Paramètres globaux du serveur DHCP
option domain-name "example.local";  # Nom de domaine interne (Active Directory si applicable)
option domain-name-servers 192.168.10.2, 8.8.8.8;  # DNS interne et externe (Google DNS en secours)
default-lease-time 600;  # Durée par défaut du bail en secondes (10 minutes)
max-lease-time 7200;     # Durée maximale du bail en secondes (2 heures)
ddns-update-style none;  # Désactiver les mises à jour dynamiques DNS

# Configuration du sous-réseau principal (LAN)
subnet 192.168.10.0 netmask 255.255.255.0 {
    range 192.168.10.50 192.168.10.200;    # Plage d'adresses IP dynamiques attribuées aux clients DHCP
    option routers 192.168.10.1;           # Adresse IP du serveur DHCP (passerelle par défaut)
    option subnet-mask 255.255.255.0;      # Masque de sous-réseau
    option domain-name-servers 192.168.10.2, 8.8.8.8;  # DNS interne et externe
}

# Configuration d'une réservation statique pour un périphérique spécifique (par exemple, un serveur ou une imprimante)
host reserved-client {
    hardware ethernet 08:00:27:bd:22:0c;   # Adresse MAC du périphérique réservé
    fixed-address 192.168.10.50;           # Adresse IP réservée au périphérique
}
```

#### Redémarrage et vérification du serveur DHCP

- Vérifiez la syntaxe du fichier de configuration

```sh
dhcpd -t
```

- Redémarrez le service DHCP

```sh
service isc-dhcp-server restart
```

- Vérifiez l'état du service

```sh
service isc-dhcp-server status
```

- Vérifiez les journaux pour détecter les erreurs ou l'activité DHCP

```sh
grep dhcpd /var/log/syslog
```

- Listez les baux actifs sur le serveur

```sh
dhcp-lease-list
```

- Affichez les détails des baux directement depuis le fichier des baux (optionnel)

```sh
cat /var/lib/dhcp/dhcpd.leases
```

#### Activer NAT pour permettre l'accès Internet aux clients

- Activez le transfert IP dans le noyau Linux

```sh
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

# Vérifiez que le transfert IP est activé
cat /proc/sys/net/ipv4/ip_forward
```

- Configurez les règles iptables NAT (remplacez eth0 par votre interface externe)

```sh
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

iptables -A FORWARD -i enp0s3 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT

iptables -A FORWARD -i eth0 -o enp0s3 -j ACCEPT

# Sauvegardez les règles iptables pour qu'elles persistent après un redémarrage
iptables-save > /etc/iptables/rules.v4

# Redémarrez la configuration réseau (optionnel)
systemctl restart networking.service
```

#### Configuration des clients DHCP

- Modifiez la configuration réseau des clients pour utiliser DHCP
- Sur un client Linux utilisant Netplan, configurez comme suit

```sh
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: yes          # Activer DHCP pour IPv4 uniquement.
```

- Appliquez la configuration sur le client

```sh
netplan apply && ifconfig enp0s3 down && ifconfig enp0s3 up && ifconfig
```

#### Vérifications finales

- Vérifiez les baux actifs côté serveur

```sh
dhcp-lease-list
```

- Surveillez les journaux côté serveur

```sh
tail -f /var/log/syslog | grep dhcpd
```
