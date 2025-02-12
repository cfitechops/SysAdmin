#### Créer un réseau Docker personnalisé

- Créez un réseau Docker avec une plage sûre, comme 172.18.x.x

```sh
docker network create --subnet=172.18.0.0/16 red-cocina
```

- Fichier sécurisé docker-compose.yml

```sh
version: '3.8'
services:
  patata-dns:
    image: ubuntu/bind9:latest
    container_name: container-patata
    networks:
      red-cocina:
        ipv4_address: 172.18.0.102
    volumes:
      - ./patata-config:/etc/bind/:ro  # Volume monté en lecture seule
    ports:
      - "1053:53/udp"
      - "1053:53/tcp"
    deploy:
      resources:
        limits:
          cpus: "0.5"  # Limite à 50% d'un CPU
          memory: "512M"  # Limite à 512 Mo de RAM
    security_opt:
      - no-new-privileges:true  # Empêche l'élévation des privilèges
    cap_drop:
      - ALL  # Supprime toutes les capacités Linux par défaut
    cap_add:
      - NET_BIND_SERVICE  # Autorise uniquement la liaison sur des ports réseau
    user: "1000:1000"  # Exécute le conteneur avec un utilisateur non root

  tortilla-dns:
    image: ubuntu/bind9:latest
    container_name: container-tortilla
    networks:
      red-cocina:
        ipv4_address: 172.18.0.103
    volumes:
      - ./tortilla-config:/etc/bind/:ro  # Volume monté en lecture seule
    ports:
      - "2053:53/udp"
      - "2053:53/tcp"
    deploy:
      resources:
        limits:
          cpus: "0.5"  # Limite à 50% d'un CPU
          memory: "512M"  # Limite à 512 Mo de RAM
    security_opt:
      - no-new-privileges:true  # Empêche l'élévation des privilèges
    cap_drop:
      - ALL  # Supprime toutes les capacités Linux par défaut
    cap_add:
      - NET_BIND_SERVICE  # Autorise uniquement la liaison sur des ports réseau
    user: "1000:1000"  # Exécute le conteneur avec un utilisateur non root

networks:
  red-cocina:
    driver: bridge
    ipam:
      config:
        - subnet: 172.18.0.0/16
```

- Assurez-vous que vos fichiers de configuration DNS sont correctement protégés avec des permissions strictes

```sh
chmod -R 750 ~/dns-config/patata-config ~/dns-config/tortilla-config
```

- Vérifiez que seuls les utilisateurs autorisés peuvent accéder à ces fichiers

```sh
chown -R $USER:$USER ~/dns-config/patata-config ~/dns-config/tortilla-config
```

- Avant de déployer vos conteneurs, scannez l'image Docker utilisée (ubuntu/bind9) pour détecter d'éventuelles vulnérabilités

```sh
sudo apt install trivy -y
```

- Scannez l'image

```sh
trivy image ubuntu/bind9:latest
```

- Déployez vos serveurs DNS en toute sécurité
  - Positionnez-vous dans le dossier contenant le fichier docker-compose.yml

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

- Installez les outils DNS sur votre machine hôte si ce n'est pas déjà fait

```sh
sudo apt update && sudo apt install dnsutils -y
```

- Tester sur container-patata (172.18.0.102)

```sh
nslookup filete.patata.com 172.18.0.102
nslookup queso.patata.com 172.18.0.102
nslookup tortilla.patata.com 172.18.0.102
```

- Tester sur container-tortilla (172.18.0.103)

```sh
nslookup cebolla.tortilla.patata.com 172.18.0.103
nslookup chorizo.tortilla.patata.com 172.18.0.103
```
