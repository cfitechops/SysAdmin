# Installer l'agent Zabbix sur Ubuntu sur le même réseau que le serveur Zabbix

- Après avoir organisé un nouveau serveur, télécharger et installer ensuite le référentiel Zabbix sur le serveur.

- Visitez la page de téléchargement de Zabbix à [https://www.zabbix.com/download](https://www.zabbix.com/download).

- Notez également que n'installez pas à nouveau le serveur Zabbix, donc peu importe les sélections que j'ai pour la base de données ou le serveur Web.

- Assurez-vous de sélectionner la version appropriée à votre système d’exploitation et à votre architecture

- Mise à jour du système

```sh
sudo apt update && sudo apt upgrade -y
```

- Recherche du paquet Zabbix

```sh
sudo apt search zabbix
```

- Assurez-vous également que vos agents utilisent la même version que votre serveur Zabbix

```sh
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-1+ubuntu24.04_all.deb

dpkg -i zabbix-release_7.0-1+ubuntu24.04_all.deb

sudo apt update
```

- Installation de Zabbix Agent
  - Zabbix Agent, qui collecte des données sur le serveur agent et les envoie au serveur Zabbix principal.

```sh
sudo apt install zabbix-agent
```

- Configuration de l'agent Zabbix

```sh
sudo nano /etc/zabbix/zabbix_agentd.conf
```

- Maintenant, pour configurer l'agent,
  - Modifiez les paramètres pour `Server`, `ServerActive`, `Hostname` et enregistrez.

```sh
Server=<IP_ZABBIX_SERVER>
ServerActive=<IP_ZABBIX_SERVER>
Hostname=<CLIENT_AGENT_NAME>
```

- Après toute modification de la configuration, vous devez redémarrer l'agent.

```sh
service zabbix-agent restart
```

- Vérifier le statut du service

```sh
sudo systemctl status zabbix-agent.service
```

- Active le pare-feu UFW

```sh
sudo ufw enable
```

- Autoriser le port 10050

```sh
sudo ufw allow 10050
```

- Recharger UFW

```sh
sudo ufw reload
```

- Enfin, ajoutez une interface pour `Agent` décrivant l'adresse IP et le port sur lesquels le serveur Zabbix trouvera l'agent, puis enregistrez.

- Allez -> `Data collection > Hosts > Create host`

![Zabbix](/assets/Zabbix_Linux_01.png)

![Zabbix](/assets/Zabbix_Linux_02.png)

![Zabbix](/assets/Zabbix_Linux_03.png)