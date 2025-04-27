# Envoyer les journaux Nginx à Elastic Stack et Filebeat

- Dans cet projet, nous allons apprendre à surveiller les journaux Nginx avec Elastic Stack et Filebeat sur Ubuntu 24.04 | Envoyer les journaux Nginx à Elastic Stack et Filebeat. La surveillance des journaux Nginx est essentielle pour suivre les erreurs, analyser les schémas de trafic et identifier les menaces de sécurité. Dans ce guide, nous allons configurer Elastic Stack (Elasticsearch, Kibana et Filebeat) sur Ubuntu 24.04 et Filebeat pour collecter les journaux Nginx. À la fin, vous disposerez d'un tableau de bord Kibana visualisant vos journaux Nginx.

- **Étape 1** : Configurer l'instance Ubuntu
  - Mettez à jour la liste des packages pour vous assurer que vous disposez des dernières versions.

```sh
sudo apt update
```

- Elasticsearch nécessite Java, nous devons donc installer OpenJDK 11.

```sh
sudo apt install openjdk-11-jdk -y
```

- Après l'installation, vérifiez que Java est correctement installé en vérifiant sa version.

```sh
java -version
```

- Installez le serveur Web Nginx.

```sh
sudo apt install nginx -y
```

- Vérifiez l’état de Nginx pour vous assurer qu’il est en cours d’exécution.

```sh
sudo systemctl status nginx
```

- Ouvrez votre navigateur et accédez à `http://<your-server-ip>`. Vous devriez voir la page d'accueil par défaut Nginx.

- **Étape 2** : Installer Elasticsearch sur Ubuntu

- Importez la clé GPG Elasticsearch.

```sh
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
```

- Ajoutez le référentiel Elasticsearch.

```sh
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
```

- Mettons maintenant à jour la liste des paquets. Le dépôt est ajouté aux sources de paquets du système.

```sh
sudo apt-get update
```

- Installez Elasticsearch.

```sh
sudo apt-get install elasticsearch
```

- Activez et démarrez Elasticsearch.

```sh
sudo systemctl start elasticsearch
sudo systemctl enable elasticsearch
```

- Vérifiez l’état d’Elasticsearch pour vous assurer qu’il est en cours d’exécution.

```sh
sudo systemctl status elasticsearch
```

- Modifier la configuration d'Elasticsearch pour l'accès à distance.

```sh
sudo nano /etc/elasticsearch/elasticsearch.yml
```

- Recherchez le network.hostparamètre, supprimez-le du commentaire et définissez-le pour `0.0.0.0` qu'il se lie à toutes les adresses IP disponibles et supprimez le commentaire de la discoverysection pour spécifier les nœuds initiaux pour la formation du cluster `discovery.seed_hosts: []`

```sh
network.host: 0.0.0.0

discovery.seed_hosts: []
```

- Pour une configuration de base (non recommandée pour la production), désactivez les fonctionnalités de sécurité.

```sh
xpack.security.enable: false
```

- Redémarrez Elasticsearch pour appliquer les modifications.

```sh
sudo systemctl restart elasticsearch
```

- Pour confirmer qu'Elasticsearch est correctement configuré, envoyez une requête HTTP de test en utilisant curl.

```sh
curl -X GET "localhost:9200"
```

- Vous devriez voir une réponse JSON.

```sh
{
  "name" : "proj1",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "FdIoT_9JQXi7xggytGl6BQ",
  "version" : {
    "number" : "8.18.0",
    "build_flavor" : "default",
    "build_type" : "deb",
    "build_hash" : "04e979aa50b657bebd4a0937389308de82c2bdad",
    "build_date" : "2025-04-10T10:09:16.444104780Z",
    "build_snapshot" : false,
    "lucene_version" : "9.12.1",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```

- Vous pouvez y accéder en utilisant un navigateur avec votre `adresse IP publique : port 9200` qui est un port par défaut pour Elasticksearch.

![ELK](/assets/apache_elk_01.png)

- **Étape 3** : Installer Kibana sur Ubuntu
  - Kibana fournit une interface web pour visualiser les données d'Elasticsearch. Installez Kibana avec la commande suivante :

```sh
sudo apt-get install kibana
```

- Activez et démarrez Kibana.

```sh
sudo systemctl start kibana
sudo systemctl enable kibana
```

- Vérifiez l'état de Kibana :

```sh
sudo systemctl status kibana
```

- Ouvrez le fichier de configuration Kibana pour le modifier

```sh
sudo nano /etc/kibana/kibana.yml
```

- Décommentez et ajustez les lignes suivantes pour lier Kibana à toutes les adresses IP et le connecter à Elasticsearch.

```sh
server.port: 5601
server.host: "0.0.0.0"
elasticsearch.hosts: ["http://localhost:9200"]
```

- Redémarrez Kibana pour appliquer les modifications.

```sh
sudo systemctl restart kibana
```

- Accédez à l'interface Kibana en naviguant vers `http://<your-server-ip>:5601` dans votre navigateur web. Le tableau de bord Kibana s'ouvrira et vous pourrez commencer à explorer vos données.

![ELK](/assets/ELK_01.png)

- Vous pouvez commencer par adding integrations ou Explore on my own.

![ELK](/assets/ELK_02.png)

- **Étape 4** : Installer Filebeat sur Ubuntu
  - Filebeat collecte et transmet les données de journal à Elasticsearch ou Logstash. Installez Filebeat sur votre système.

```sh
sudo apt install -y filebeat
```

- Il n'est pas nécessaire de modifier la configuration de Filebeat car par défaut, il est configuré pour envoyer des journaux à Elasticsearch.

- Activez le module Nginx dans Filebeat.

```sh
sudo filebeat modules enable nginx
```

- Configurer le module Nginx.

```sh
sudo nano /etc/filebeat/modules.d/nginx.yml
```

- Assurez-vous que la configuration suivante est activée pour envoyer les journaux Nginx.

```sh
- module: nginx
  # Access logs
  access:
    enabled: true

    # Set custom paths for the log files. If left empty,
    # Filebeat will choose the paths depending on your OS.
    var.paths: ["/var/log/nginx/access.log*"]

  # Error logs
  error:
    enabled: true

    # Set custom paths for the log files. If left empty,
    # Filebeat will choose the paths depending on your OS.
    var.paths: ["/var/log/nginx/error.log*"]

  # Ingress-nginx controller logs. This is disabled by default. It could be used in Kubernetes environments to parse ingress-nginx logs
  ingress_controller:
    enabled: false

    # Set custom paths for the log files. If left empty,
    # Filebeat will choose the paths depending on your OS.
    #var.paths:
```

- Enregistrez et quittez le fichier.

- Tester la configuration.

```sh
sudo filebeat test config
```

- Appliquer les modifications de configuration de Filebeat.

```sh
sudo filebeat setup
```

- Démarrez et activez le service Filebeat.

```sh
sudo systemctl enable filebeat
sudo systemctl start filebeat
```

- Vérifie l'état de filebeat.

```sh
sudo systemctl status filebeat
```

- Assurez-vous qu'Elasticsearch reçoit des données de Filebeat en vérifiant les index.

```sh
curl -XGET "localhost:9200/_cat/indices?v"
```

- Vous devriez voir une sortie indiquant la présence d’index créés par Filebeat.

![ELK](/assets/ELK_04.png)

- **Étape 5** : Vérifier les journaux Nginx dans Kibana

  - Revenez maintenant à Kibana. Faites défiler la page vers le bas et cliquez sur l' option `Journaux` dans Observability , dans le menu de navigation de gauche. Si le menu est réduit, cliquez sur l' icône `Développer` en bas à gauche pour afficher les options.

![ELK](/assets/apache_elk_02.png)

- Kibana affiche les données des `journaux Nginx des 15 dernières minutes`, sous forme d'histogramme, ainsi que les messages individuels en dessous. (Vous devrez peut-être ajuster la période.)

![ELK](/assets/apache_elk_03.png)

- **Étape 6** : Génération d'une erreur 404 dans Nginx à des fins de test
  - Pour générer une erreur 404 Not Found et la voir dans Kibana, accédez à la page suivante sur le navigateur.

```sh
http://<public-ip-address>/this-page-does-not-exist
```

- Cette demande sera enregistrée dans le journal d'accès d'Nginx et devrait être visible dans Kibana.

![ELK](/assets/apache_elk_04.png)

- Actualisez maintenant la page des journaux Kibana.

![ELK](/assets/apache_elk_05.png)

- Vous pouvez même consulter les détails de vos journaux Nginx, ainsi que les coordonnées de notre fournisseur cloud et d'autres informations.

![ELK](/assets/apache_elk_06.png)

- **Conclusion**:

  - Dans ce projet, nous avons installé avec succès la suite Elastic (Elasticsearch, Kibana et Filebeat) pour surveiller les journaux Nginx sur Ubuntu 24.04. Nous avons configuré Filebeat pour collecter les journaux d'accès et d'erreurs Nginx, garantissant ainsi une ingestion et une visualisation fluides des données. Grâce à cette configuration, vous pouvez suivre efficacement le trafic web, détecter les erreurs et améliorer les performances du serveur.
