# Elastic Stack

- Dans cet projet, nous allons découvrir comment installer la suite Elastic sur Ubuntu 24.04 LTS. La suite ELK se compose d'Elasticsearch, de Logstash et de Kibana, Filebeat étant souvent utilisé pour envoyer les journaux à Logstash. Cette puissante combinaison est essentielle pour la journalisation centralisée, la visualisation des données et l'analyse en temps réel. Nous vous guiderons dans l'installation et la configuration de chaque composant de la suite ELK, et vérifierons leur configuration.

- **Étape 1** : Installer Java pour Elastic Stack sur Ubuntu 24.04 LTS
  - Commencez par mettre à jour l’index des packages de votre système.

```sh
sudo apt update
```

- Installez le package apt-transport-https pour accéder au référentiel via HTTPS

```sh
sudo apt install apt-transport-https
```

- Les composants Elastic Stack nécessitent Java. Nous installerons OpenJDK 11, une implémentation open source largement utilisée de la plateforme Java.

```sh
sudo apt install openjdk-11-jdk -y
```

- Après l'installation, vérifiez que Java est correctement installé en vérifiant sa version.

```sh
java -version
```

- Pour garantir que les composants de la pile puissent localiser Java, nous devons définir la `JAVA_HOME` variable d'environnement. Ouvrez le fichier d'environnement.

```sh
sudo nano /etc/environment
```

- Ajoutez la ligne suivante à la fin du fichier.

```sh
JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
```

- Appliquez les modifications en rechargeant l'environnement.

```sh
source /etc/environment
```

- Vérifiez que `JAVA_HOMEle` réglage est correct.

```sh
echo $JAVA_HOME
```

- **Étape 2** : Installer ElasticSearch sur Ubuntu 24.04 LTS
  - Elasticsearch est le composant principal de la pile ELK, utilisé pour la recherche et l'analyse. Nous devons importer la clé de signature publique et ajouter le référentiel APT Elasticsearch à votre système.

```sh
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
```

- Ajoutez la définition du référentiel.

```sh
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
```

- Mettez à nouveau à jour les listes de packages pour inclure le nouveau référentiel Elasticsearch.

```sh
sudo apt-get update
```

- Installez Elasticsearch.

```sh
sudo apt-get install elasticsearch
```

- Démarrez Elasticsearch et configurez-le pour qu'il s'exécute au démarrage du système.

```sh
sudo systemctl start elasticsearch
sudo systemctl enable elasticsearch
```

- Vérifiez qu’Elasticsearch est en cours d’exécution.

```sh
sudo systemctl status elasticsearch
```

- **Étape 3** : Configurer Elasticsearch sur Ubuntu 24.04 LTS
  - Pour autoriser l'accès externe à Elasticsearch, modifiez le fichier de configuration.

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
  "cluster_uuid" : "VdCaoCSpQEummInF0-fr_w",
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

- **Étape 4** : Installer Logstash sur Ubuntu 24.04 LTS
  - Logstash permet de traiter et de transmettre les données de journal à Elasticsearch. Installez Logstash avec la commande suivante :

```sh
sudo apt-get install logstash -y
```

- Démarrez et activez Logstash.

```sh
sudo systemctl start logstash
sudo systemctl enable logstash
```

- Vérifiez l'état du service.

```sh
sudo systemctl status logstash
```

- **Étape 5** : Installer Kibana sur Ubuntu 24.04 LTS
  - Kibana fournit une interface web pour visualiser les données d'Elasticsearch. Installez Kibana avec la commande suivante :

```sh
sudo apt-get install kibana
```

- Démarrez et activez le service Kibana.

```sh
sudo systemctl start kibana
sudo systemctl enable kibana
```

- Vérifiez l'état de Kibana :

```sh
sudo systemctl status kibana
```

- **Étape n°6** : configurer Kibana sur Ubuntu 24.04 LTS
  - Pour configurer Kibana pour un accès externe, modifiez le fichier de configuration.

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

- **Étape 7** : Installer Filebeat sur Ubuntu 24.04 LTS
  - Filebeat est un expéditeur léger permettant de transférer et de centraliser les données de journal. Installez Filebeat avec la commande suivante :

```sh
sudo apt-get install filebeat
```

- Ouvrez le fichier de configuration Filebeat pour envoyer les journaux à Logstash.

```sh
sudo nano /etc/filebeat/filebeat.yml
```

- Commentez la section de sortie Elasticsearch.

```sh
# output.elasticsearch:
 #  hosts: ["localhost:9200"]
```

- Décommentez et configurez la section de sortie Logstash.

```sh
output.logstash:
  hosts: ["localhost:5044"]
```

![ELK](/assets/ELK_03.png)

- Activez le module système, qui collecte les données de journal du système local.

```sh
sudo filebeat modules enable system
```

- Configurez Filebeat pour charger le modèle d’index dans Elasticsearch.

```sh
sudo filebeat setup --index-management -E output.logstash.enabled=false -E 'output.elasticsearch.hosts=["0.0.0.0:9200"]'
```

- Démarrez et activez le service Filebeat.

```sh
sudo systemctl start filebeat
sudo systemctl enable filebeat
```

- Assurez-vous qu'Elasticsearch reçoit des données de Filebeat en vérifiant les index.

```sh
curl -XGET "localhost:9200/_cat/indices?v"
```

- Vous devriez voir une sortie indiquant la présence d’index créés par Filebeat

![ELK](/assets/ELK_04.png)

- Vous pouvez y accéder en utilisant un navigateur en utilisant `http://<your-server-ip>:9200/_cat/indices?v`

![ELK](/assets/ELK_05.png)

- **Conclusion**:

  - En conclusion, nous avons installé et configuré avec succès la suite Elastic sur Ubuntu 24.04 LTS. Cela incluait la configuration d'Elasticsearch pour la recherche et l'analyse, de Logstash pour le traitement des données, de Kibana pour la visualisation des données et de Filebeat pour l'envoi des journaux. La suite Elastic offre une solution robuste pour la journalisation et l'analyse centralisées des données, ce qui la rend précieuse pour la surveillance et l'analyse des performances système et des journaux applicatifs.
