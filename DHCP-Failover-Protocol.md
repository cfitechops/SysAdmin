# Failover DHCP

#### Mise à jour et installation des packages requis

```sh
sudo apt update && sudo apt upgrade -y
sudo apt install -y isc-dhcp-server wireshark vim net-tools build-essential linux-headers-$(uname -r)
```

#### Configuration de l'adresse IP statique pour le serveur principal

- Modifier le fichier Netplan

```sh
nano /etc/netplan/cfg-static-ip.yaml
```

- Ajouter la configuration suivante

```sh
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      addresses:
        - 192.168.1.2/24
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
      routes:
        - to: default
          via: 192.168.1.1
```

- Appliquer la configuration

```sh
chmod 600 /etc/netplan/cfg-static-ip.yaml
netplan apply
ip a
```

#### Configuration du serveur DHCP sur le serveur principal

- Modifier le fichier /etc/default/isc-dhcp-server

```sh
nano /etc/default/isc-dhcp-server
```

- Ajouter l'interface réseau

```sh
INTERFACESv4="enp0s3"
```

- Modifier le fichier /etc/dhcp/dhcpd.conf

```sh
gedit /etc/dhcp/dhcpd.conf
```

- Ajouter la configuration suivante

```sh
authoritative;
ddns-update-style none;

failover peer "FAILOVER" {
  primary;
  address 192.168.1.2;
  port 647;
  peer address 192.168.1.3;
  peer port 647;
  max-unacked-updates 10;
  max-response-delay 30;
  load balance max seconds 3;
  mclt 1800;
  split 128;
}

subnet 192.168.1.0 netmask 255.255.255.0 {
  option broadcast-address 192.168.1.255;
  option routers 192.168.1.1;
  option domain-name-servers 8.8.8.8, 8.8.4.4;
  pool {
    failover peer "FAILOVER";
    max-lease-time 3600;
    range 192.168.1.50 192.168.1.199;
  }
}
```

- Tester et redémarrer le service DHCP

```sh
dhcpd -t
service isc-dhcp-server restart
service isc-dhcp-server status
```

#### Cloner le serveur principal pour créer un serveur secondaire

- Modifier l'adresse IP statique dans /etc/netplan/cfg-static-ip.yaml

```sh
nano /etc/netplan/cfg-static-ip.yaml
```

- Ajouter la configuration suivante

```sh
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: no
      addresses:
        - 192.168.1.3/24
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]
```

- Appliquer la configuration Netplan

```sh
netplan apply
```

#### Configuration du basculement DHCP sur le serveur secondaire

- Modifier /etc/dhcp/dhcpd.conf sur le serveur secondaire

```sh
gedit /etc/dhcp/dhcpd.conf
```

- Ajouter cette configuration

```sh
authoritative;
ddns-update-style none;

failover peer "FAILOVER" {
  secondary;
  address 192.168.1.3;
  port 647;
  peer address 192.168.1.2;
  peer port 647;
  max-unacked-updates 10;
  max-response-delay 30;
  load balance max seconds 3;
}

subnet 192.168.1.0 netmask 255.255.255.0 {
  option broadcast-address 192.168.1.255;
  option routers 192.168.1.1;
  option domain-name-servers 8.8.8.8, 8.8.4.4;
  pool {
    failover peer "FAILOVER";
    max-lease-time 3600;
    range 192.168.1.50 192.168.1.199;
  }
}
```

#### Redémarrer et vérifier le serveur DHCP secondaire

- Redémarrez le service DHCP sur le serveur secondaire

```sh
service isc-dhcp-server restart
```

- Vérifiez l'état du service pour vous assurer qu'il fonctionne correctement

```sh
service isc-dhcp-server status
```

- Utilisez **Wireshark** pour surveiller la communication entre les serveurs primaire et secondaire
  - Ouvrez Wireshark sur le serveur secondaire
  - Appliquez un filtre pour les ports liés au failover DHCP

```sh
tcp.port == 647 || udp.port == 647 || dhcp
```

- Capturez les paquets et vérifiez que la communication entre les deux serveurs est visible.

#### Tester le basculement DHCP avec une machine cliente

- Libérez tout bail DHCP existant

```sh
sudo dhclient -r
```

- Demandez un nouveau bail DHCP

```sh
sudo dhclient -v
```

- Vérifiez que la machine cliente obtient une adresse IP dans la plage configurée (par exemple, 192.168.1.50 à 192.168.1.199).

#### Simuler un scénario de basculement sur le serveur principal

- Arrêtez le service DHCP

```sh
service isc-dhcp-server stop
```

- Vérifiez que le service est arrêté

```sh
service isc-dhcp-server status
```

#### Sur la machine cliente

- Libérez l'adresse IP actuelle

```sh
sudo dhclient -r
```

- Renouvelez l'adresse IP

```sh
sudo dhclient -v
```

- Vérifiez que la machine cliente obtient une adresse IP du serveur secondaire.

#### Restaurer le serveur principal

- Redémarrez le service DHCP sur le serveur principal

```sh
service isc-dhcp-server start
```

- Vérifiez que le serveur principal reprend son rôle dans la relation de basculement

```sh
service isc-dhcp-server status
```

#### Conseils de dépannage

- Si les clients ne parviennent pas à obtenir une adresse IP, examinez les journaux sur les deux serveurs

```sh
tail -f /var/log/syslog
```

- Assurez-vous que les deux serveurs peuvent communiquer via le port TCP 647.
- Utilisez des outils comme tcpdump ou Wireshark pour analyser le trafic réseau.

#### Note:

- Ce code complet garantit une configuration fonctionnelle du basculement DHCP, avec des tests pour vérifier que les clients continuent d'obtenir des adresses IP même en cas de panne du serveur principal.
