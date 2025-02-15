# DNS BIND9 Docker

#### Comment installer Docker sur Ubuntu 22.04

- Configurer le aptréférentiel Docker.

```sh
# Ajoutez la clé GPG officielle de Docker :
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Ajoutez le dépôt aux sources Apt :
echo \
  "deb [arch= $(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo " $VERSION_CODENAME " ) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

- Installez les packages Docker.

```sh
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

- Ajoutez l’utilisateur connecté « $USER » au dockergroupe

```sh
sudo gpasswd -a $USER docker
```

- Effectuez une newgrp docker

```sh
newgrp docker
```

- Lancer un conteneur temporaire pour extraire la configuration par défaut

```sh
sudo -i
docker run -d --name bind9-tmp ubuntu/bind9
docker cp bind9-tmp:/etc/bind config
docker rm -f bind9-tmp
```

- Créer les dossiers de configuration pour patata et tortilla

```sh
cp -r config/ patata-config
cp -r config/ tortilla-config
```

#### Configurer le serveur DNS patata

- Fichier patata-config/named.conf.local

```sh
zone "patata.com" {
        type master;
        file "/etc/bind/db.patata.com";
};
```

- Fichier patata-config/db.patata.com

```sh
$TTL	604800
$ORIGIN patata.com.
@	          IN	    SOA	    ns.patata.com. root.patata.com. (
                            2025040201    ; Serial
                                604800    ; Refresh
                                 86400    ; Retry
                               2419200    ; Expire
                              604800 )    ; Negative Cache TTL

@           IN      NS      ns.patata.com.
@           IN      A       192.168.129.102
ns          IN      A       192.168.129.102

steak       IN      A       1.1.1.1
fromage     IN      A       2.2.2.2

; ----------------------------------------
; Delegated subdomain: tortilla.patata.com
; ----------------------------------------

$ORIGIN tortilla.patata.com.

@           IN      NS      ns.tortilla.patata.com.
ns          IN      A       192.168.129.103
```

#### Configurer le serveur DNS tortilla

- Fichier tortilla-config/named.conf.local

```sh
zone "tortilla.patata.com" {
        type master;
        file "/etc/bind/db.tortilla.patata.com";
};
```

- Fichier tortilla-config/db.tortilla.patata.com

```sh
$TTL	604800
$ORIGIN tortilla.patata.com.
@	          IN	    SOA	    ns.tortilla.patata.com. root.tortilla.patata.com. (
                            2025040201    ; Serial
                                604800    ; Refresh
                                 86400    ; Retry
                               2419200    ; Expire
                              604800 )    ; Negative Cache TTL

@           IN      NS      ns.tortilla.patata.com.
@           IN      A       192.168.129.103
ns          IN      A       192.168.129.103

oignon      IN      A       3.3.3.3
saucisse    IN      A       4.4.4.4
```

- Créer un réseau Docker pour les conteneurs DNS

```sh
docker network create --subnet=192.168.128.0/23 red-cocina
```

- Lancer les conteneurs DNS avec leurs configurations respectives

```sh
docker run -d --name container-patata --net red-cocina --ip 192.168.129.102 -v $PWD/patata-config:/etc/bind/ ubuntu/bind9

docker run -d --name container-tortilla --net red-cocina --ip 192.168.129.103 -v $PWD/tortilla-config:/etc/bind/ ubuntu/bind9
```

- Vérifier que les conteneurs sont en cours d'exécution

```sh
docker ps
```

- Installer les outils DNS sur la machine hôte

```sh
apt update && apt install -y dnsutils
```

- Tester les enregistrements sur patata

```sh
nslookup steak.patata.com 192.168.129.102
nslookup fromage.patata.com 192.168.129.102
nslookup patata.com 192.168.129.102
```

- Tester les enregistrements sur tortilla

```sh
nslookup tortilla.patata.com 192.168.129.103
nslookup saucisse.tortilla.patata.com 192.168.129.103
nslookup oignon.tortilla.patata.com 192.168.129.103
```
