#### Créer deux serveurs DNS avec BIND9 dans des conteneurs Docker

- **container-patata** : Gère la zone principale patata.com.
- **container-tortilla** : Gère le sous-domaine délégué tortilla.patata.com.

#### Créer un réseau Docker personnalisé

- Créez un réseau Docker avec une plage d'adresses IP dédiée

```sh
docker network create --subnet=192.168.128.0/23 red-cocina
```

#### Configurer les fichiers de zones DNS

- Structure des dossiers
  - Créez des dossiers pour chaque serveur DNS et leurs configurations

```sh
mkdir -p ~/dns-config/patata-config ~/dns-config/tortilla-config
```

#### Fichiers de configuration pour container-patata

- Fichier named.conf.local

```sh
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

- Fichier db.patata.com

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
        IN      A       192.168.129.102
        
ns      IN      A       192.168.129.102

filete  IN      A       1.1.1.1
queso   IN      A       2.2.2.2

tortilla IN      NS      ns.tortilla.patata.com.
```

#### Fichiers de configuration pour container-tortilla

- Fichier named.conf.local

```sh
nano ~/dns-config/tortilla-config/named.conf.local
```

- Contenu

```sh
zone "tortilla.patata.com" {
    type master;
    file "/etc/bind/db.tortilla.patata.com";
};
```

- Fichier db.tortilla.patata.com

```sh
nano ~/dns-config/tortilla-config/db.tortilla.patata.com
```

- Contenu

```sh
$TTL    604800
@       IN      SOA     ns.tortilla.patata.com. root.tortilla.patata.com. (
                        2025040201 ; Serial
                        10h        ; Refresh interval
                        15m        ; Retry interval
                        48h        ; Expire interval
                        604800     ; Negative Cache TTL
                        )

        IN      NS      ns.tortilla.patata.com.
        IN      A       192.168.129.103

ns      IN      A       192.168.129.103

cebolla IN      A       3.3.3.3
chorizo IN      A       4.4.4.4
```

#### Créer un fichier Docker Compose

- Utilisez Docker Compose pour automatiser le déploiement des serveurs DNS.
  - Créez un fichier docker-compose.yml

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
        ipv4_address: 192.168.129.102
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
        ipv4_address: 192.168.129.103
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
        - subnet: 192.168.128.0/23
```

#### Déployer les serveurs DNS

- Positionnez-vous dans le dossier contenant docker-compose.yml

```sh
cd ~/dns-config/
```

- Lancez les services avec Docker Compose

```sh
docker-compose up -d
```

- Vérifiez que les conteneurs sont en cours d'exécution

```sh
docker ps
```

#### Tester la résolution DNS

- Installez les outils DNS si ce n'est pas déjà fait (sur la machine hôte)

```sh
sudo apt update && sudo apt install dnsutils -y
```

- Tester les enregistrements sur container-patata (192.168.129.102)

```sh
nslookup filete.patata.com 192.168.129.102
nslookup queso.patata.com 192.168.129.102
nslookup tortilla.patata.com 192.168.129.102
```

- Tester les enregistrements sur container-tortilla (192.168.129.103)

```sh
nslookup cebolla.tortilla.patata.com 192.168.129.103
nslookup chorizo.tortilla.patata.com 192.168.129.103
```

#### Note:

- DNS robuste et portable grâce à Docker, adaptée aux environnements professionnels.
