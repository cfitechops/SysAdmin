#### Modifier le fichier Netplan

- Modifiez le fichier /etc/netplan/50-cloud-init.yaml

```sh
sudo nano /etc/netplan/50-cloud-init.yaml
```

- Remplacez le contenu par

```sh
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: false
      addresses:
        - 192.168.2.22/24
      routes:
        - to: default
          via: 192.168.2.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
```

#### Appliquer les modifications

- Appliquez les modifications avec Netplan

```sh
sudo netplan apply
```

#### Vérifier la nouvelle configuration

- Vérifiez que votre interface réseau utilise bien la nouvelle adresse IP

```sh
ip addr show enp0s3
```

#### Créer un réseau Docker personnalisé

- Créez un réseau Docker avec une plage sûre, comme 172.18.x.x

```sh
docker network create --subnet=172.18.0.0/16 red-cocina
```

#### Préparer les fichiers de configuration DNS

- Créez les fichiers nécessaires pour vos serveurs DNS dans des dossiers séparés.
  - Configuration pour container-patata

```sh
mkdir -p ~/dns-config/patata-config/
nano ~/dns-config/patata-config/named.conf.local
```

- Contenu

```sh
zone "patata.com" {
    type master;
    file "/etc/bind/db.patata.com";
};

zone "tortilla.patata.com" {
    type delegation-only;
};
```

```sh
nano ~/dns-config/patata-config/db.patata.com
```

- Contenu

```sh
$TTL    604800
@       IN      SOA     ns.patata.com. root.patata.com. (
                        2025040201 ; Serial
                        10h        ; Refresh interval
                        15m        ; Retry interval
                        48h        ; Expire interval
                        604800     ; Negative Cache TTL
                        )

        IN      NS      ns.patata.com.
        IN      A       172.18.0.102

ns      IN      A       172.18.0.102

filete  IN      A       1.1.1.1
queso   IN      A       2.2.2.2

tortilla IN      NS      ns.tortilla.patata.com.
```

- Configuration pour container-tortilla

```sh
mkdir -p ~/dns-config/tortilla-config/
nano ~/dns-config/tortilla-config/named.conf.local
```

- Contenu

```sh
zone "tortilla.patata.com" {
    type master;
    file "/etc/bind/db.tortilla.patata.com";
};
```

```sh
nano ~/dns-config/tortilla-config/db.tortilla.patata.com
```

- Contenu

```sh
$TTL    604800
@       IN      SOA     ns.tortilla.patata.com.root.tortilla.patata.com (
                        2025040201 ; Serial
                        10h        ; Refresh interval
                        15m        ; Retry interval
                        48h        ; Expire interval
                        )

        IN      NS      ns.tortilla.patata.com.
        IN      A       172.18.0.103

ns      IN      A       172.18.0.103

cebolla IN      A       3.3.3.3
chorizo IN      A       4.4.4.4
```

#### Créer un fichier Docker Compose

- Créez un fichier docker-compose.yml pour automatiser le déploiement des conteneurs.

```sh
nano ~/dns-config/docker-compose.yml
```

- Contenu du fichier

```sh
version: '3'
services:
  patata-dns:
    image: ubuntu/bind9:latest
    container_name: container-patata
    networks:
      red-cocina:
        ipv4_address: 172.18.0.102
    volumes:
      - ./patata-config:/etc/bind/
    ports:
      - "1053:53/udp"
      - "1053:53/tcp"

  tortilla-dns:
    image: ubuntu/bind9:latest
    container_name: container-tortilla
    networks:
      red-cocina:
        ipv4_address: 172.18.0.103
    volumes:
      - ./tortilla-config:/etc/bind/
    ports:
      - "2053:53/udp"
      - "2053:53/tcp"

networks:
  red-cocina:
    driver: bridge
    ipam:
      config:
        - subnet: 172.18.0.0/16
```

#### Lancer les conteneurs

- Positionnez-vous dans le dossier contenant le fichier docker-compose.yml

```sh
cd ~/dns-config/
docker-compose up -d
```

- Vérifiez que les conteneurs fonctionnent correctement

```sh
docker ps
```

- Installez les outils DNS sur votre machine hôte si ce n'est pas déjà fait

```sh
sudo apt update && sudo apt install dnsutils -y
```

- Tester sur container-patata (172.18.0.102)

```sh
nslookup filete.patata.com 172.18.0.102
nslookup queso.patata.com 172.18.0.102
nslookup tortilla.patata.com 172.18.0.103
```
