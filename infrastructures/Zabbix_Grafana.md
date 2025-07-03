# Installation de Grafana avec intégration Zabbix

#### Installation de Grafana

```sh
sudo apt install -y apt-transport-https software-properties-common wget
sudo mkdir -p /etc/apt/keyrings/

wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null

echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

sudo apt update
sudo apt install -y grafana

sudo systemctl start grafana-server
sudo systemctl enable grafana-server
```

- Grafana est maintenant disponible sur `http://<IP>:3000`

- Login par défaut : `admin / admin` (pense à le modifier)

![grafana](/assets/grafana_01.png)

![grafana](/assets/grafana_02.png)

#### Installation du plugin Zabbix pour Grafana

```sh
sudo grafana-cli plugins install alexanderzobnin-zabbix-app
sudo systemctl restart grafana-server
```

- Ensuite dans Grafana :

- **"Configuration -> Plugins"** > Rechercher `Zabbix` > Cliquer sur **Enable**

![grafana](/assets/grafana_03.png)

![grafana](/assets/grafana_04.png)

![grafana](/assets/grafana_05.png)

![grafana](/assets/grafana_06.png)

![grafana](/assets/grafana_07.png)

#### Configuration de la connexion API Zabbix

```sh
http://<IP_ZABBIX>/zabbix/api_jsonrpc.php
```

- Aller dans "**Configuration**" > "**Data Sources**"

![grafana](/assets/grafana_08.png)

- Ajouter une source de données de type **Zabbix**

![grafana](/assets/grafana_09.png)

- URL de l'API : `http://<IP_ZABBIX>/zabbix/api_jsonrpc.php`

![grafana](/assets/grafana_10.png)

- Authentification : identifiants d’un **compte Zabbix avec droits d'accès**

![grafana](/assets/grafana_11.png)

- Cocher : `Trends` si tu les utilises

- Intervalle de mise à jour : `1m` recommandé

![grafana](/assets/grafana_12.png)

#### Importation d’un Dashboard Zabbix

- Lien du dashboard : [Dashboard Zabbix Full Server Status (ID: 5363)](https://grafana.com/grafana/dashboards/5363-zabbix-full-server-status/)

- Grafana -> "+" -> **Import**

![grafana](/assets/grafana_13.png)

- Entrer l’ID : `5363`

![grafana](/assets/grafana_14.png)

- Sélectionner la source Zabbix

- Valider

![grafana](/assets/grafana_15.png)

![grafana](/assets/grafana_16.png)
