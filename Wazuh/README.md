# Introduction

- La cybersécurité est aujourd’hui un enjeu majeur pour toutes les entreprises. Pour se protéger contre les menaces, il existe des outils capables de **détecter des comportements anormaux**, **alerter les administrateurs**, et **automatiser des réactions**.

- Parmi ces outils, **Wazuh** est l’une des solutions les plus complètes et accessibles, capable de surveiller à la fois les fichiers, les connexions, les vulnérabilités et même les attaques réseau.

## Wazuh

- **Wazuh**, c’est un outil **gratuit et open source** qui aide à **protéger les ordinateurs, les serveurs, le cloud et même les conteneurs** (des petits systèmes qu’on utilise dans l’informatique moderne).

- Il sert à **surveiller la sécurité** d’un réseau ou d’une entreprise.
  On peut dire que **Wazuh est comme une alarme intelligente** pour l’informatique.

#### À quoi sert Wazuh ?

- Wazuh permet de :

  - Analyser ce qu’il se passe dans les machines : qui s’est connecté, quels programmes ont été lancés…

  - Repérer les tentatives d’attaque ou de piratage

  - Vérifier que les règles de sécurité sont respectées (par exemple : RGPD, normes bancaires, etc.)

#### Un peu d’histoire

- Avant Wazuh, il y avait un autre outil appelé **OSSEC**.

  - Créé en **2004**, OSSEC était déjà un système d’alerte pour les ordinateurs.

  - En **2015**, Wazuh est né à partir d’OSSEC, avec **plus de fonctions et une interface plus moderne**.

#### Détection sur les machines

- Wazuh est installé **sur chaque ordinateur ou serveur**.

- Il regarde discrètement ce qu’il s’y passe : fichiers modifiés, programmes lancés, erreurs...

#### Interface de contrôle

- Il a une jolie **interface** (comme un tableau de bord), où on peut tout voir facilement : alertes, rapports, état des machines…

#### Conformité

- Il vérifie si l’entreprise suit bien les lois et règles de sécurité (exemples : RGPD, sécurité des données bancaires...).

#### Sécurité dans le cloud

- Wazuh peut aussi surveiller **les services dans le cloud** comme **Amazon AWS, Microsoft Azure** ou **Google Cloud**.

## De quoi est composé Wazuh ?

- Wazuh fonctionne comme une équipe bien organisée :

```sh
| Élément            | Rôle simplifié                                    |
| ------------------ | ------------------------------------------------- |
| 🧠 Serveur         | Il reçoit les infos des machines, analyse, alerte |
| 📦 Indexeur        | Il stocke toutes les infos pour les retrouver     |
| 👓 Tableau de bord | C’est l’écran de contrôle (interface web)         |
| 👂 Agents          | Installés sur les machines pour tout surveiller   |
```

## Comment ça marche ?

- **Les agents** regardent ce qui se passe sur chaque machine.

- Ils **envoient les infos** au serveur central.

- Le serveur **analyse** ces infos et détecte ce qui semble dangereux.

- Les résultats sont **affichés sur l’interface** qu’on peut consulter.

- Toutes les communications sont **chiffrées** (sécurisées) pour éviter les écoutes.

## Intégrations utiles

- Wazuh peut travailler avec d’autres outils, par exemple :

  - **VirusTotal** : pour vérifier si un fichier est dangereux

  - **Elastic ou Splunk** : pour visualiser encore mieux les alertes

## Exemple de détection simple

- Imaginons qu’un pirate essaie de deviner un mot de passe sur un serveur SSH.

- Wazuh a des **règles prêtes à l’emploi** qui détectent ce genre d’attaque et donnent une alerte **avec un niveau de gravité** (de 0 à 15).

## Résumé en 3 points simples

- 1 - **Wazuh surveille** tout ce qu’il se passe dans votre infrastructure informatique.

- 2 - Il **détecte les comportements suspects ou dangereux**.

- 3 - Il **vous alerte** et vous aide à prendre les bonnes décisions pour rester en sécurité.

## Architecture

```sh
                   +--------------+
                   | Tableau de   |
                   |   bord       |
                   +------+-------+
                          |
                    +-----v-----+
                    |  Serveur   |
                    +-----+-----+
                          |
     +--------------------+--------------------+
     |                    |                    |
+----v----+         +-----v-----+        +-----v-----+
| Agent 1 |         | Agent 2   |        | Agent 3   |
| (Linux) |         | (Windows) |        | (Cloud)   |
+---------+         +-----------+        +-----------+
```

# Lab 1 – Surveillance des fichiers importants (FIM)

## Objectif

- Apprendre à détecter quand un **fichier système important est modifié**.

#### Étapes

- Aller dans le dossier `/etc` (sous Linux).

- Modifier un fichier comme `hosts` ou `passwd`.

- Ouvrir le **dashboard Wazuh**.

- Repérer une alerte indiquant que le fichier a été changé.

#### Résultat attendu

- Une alerte s’affiche car un fichier sensible a été modifié, ce qui peut indiquer une attaque.

# Lab 2 – Détection d’attaques réseau avec Suricata

## Objectif

- Détecter une **attaque réseau simulée** comme un scan de ports.

#### Étapes

- Installer Suricata, un outil qui surveille le trafic réseau.

- Configurer Suricata pour envoyer ses données à Wazuh (en format JSON).

- Depuis une autre machine, lancer un scan de ports avec Nmap.

- Regarder le dashboard Wazuh pour voir une alerte.

#### Résultat attendu

- Une alerte s’affiche car une activité réseau suspecte a été détectée (ex. : scan).

# Lab 3 – Analyse des vulnérabilités

## Objectif

- Détecter si un logiciel installé est **vulnérable** (présente une faille de sécurité connue).

#### Étapes

- Activer le module "**Vulnerability Detector**" dans Wazuh.

- Laisser Wazuh scanner le système automatiquement.

- Aller dans le menu **Security > Vulnerability**.

#### Résultat attendu

- Une liste des **logiciels vulnérables** s’affiche, avec des détails.

# Lab 4 – Détection de commandes malveillantes

## Objectif

- Simuler un comportement dangereux (comme un pirate) pour voir si Wazuh le détecte.

#### Étapes

- Taper une commande risquée comme : `rm -rf /test ou chmod 777 monscript.sh`

- Observer si une alerte est créée (Wazuh utilise des règles).

#### Résultat attendu

- Alerte générée car ces commandes sont **potentiellement dangereuses**.

# Lab 5 – Attaque brute-force sur SSH

## Objectif

- Simuler une **attaque par mot de passe** contre un serveur SSH.

#### Étapes

- Utiliser un outil comme **Hydra** pour deviner les mots de passe.

- Wazuh détecte les tentatives répétées.

- Vérifier que l’adresse de l’attaquant est **bloquée automatiquement**.

- Ouvrir le fichier `/etc/hosts.deny` pour le confirmer.

#### Résultat attendu

- Une alerte de tentative de connexion excessive.

- Blocage automatique de l’adresse IP.

# Lab 6 – Vérification d’un fichier suspect avec VirusTotal

## Objectif

- Analyser un fichier téléchargé pour savoir s’il est dangereux.

#### Étapes

- Télécharger un fichier suspect (ex. : via curl).

- Wazuh envoie automatiquement le fichier à **VirusTotal**.

- Vérifier l’alerte dans le dashboard avec les résultats de l’analyse.

#### Résultat attendu

- Une alerte contenant le **score de dangerosité du fichier**.

- Si le fichier est malveillant, une notification est générée.

### Installation Wazuh

#### Installation AGENT

- Script d'installation de l'agent linux

![agent](/Wazuh/assets/01.png)

![agent](/Wazuh/assets/02.png)

- Script d'installation de l'agent windows : `C:\Program Files > ossec-agent > win32ui`

- [CONFIGURATIONS SPÉCIFIQUES](https://documentation.wazuh.com/current/user-manual/ruleset/ruleset-xml-syntax/rules.html)

- **Lab #1:** File Integrity Monitoring (FIM)

  - Configuration FIM - Manager

```sh
docker ps

docker exec -it single-node-wazuh.manager-1 bash

/var/ossec/bin/wazuh-control restart

apt update && apt install -y nano
```

```sh
nano /var/ossec/etc/ossec.conf
```

- Modification ceci dans le fichier de configuration de Wazuh Manager

```sh
<ossec_config>
  <global>
    <jsonout_output>yes</jsonout_output>
    <alerts_log>yes</alerts_log>
    <logall>yes</logall>
    <logall_json>yes</logall_json>
  </global>
</ossec_config>
```

```sh
service wazuh-manager restart
```

- Configuration Agent

```sh
nano /var/ossec/etc/ossec.conf
```

- Ajout ceci dans le fichier de configuration de Wazuh Agent

```sh
<syscheck>
  <directories check_all="yes" realtime="yes" report_changes="yes">/root</directories>
  <frequency>3600</frequency>
  <scan_on_start>yes</scan_on_start>
</syscheck>
```

```sh
systemctl restart wazuh-agent
touch samplefile.txt
```

- Dans l'interface Wazuh : `Modules > agent01 > Security events`

- **Lab #2:** Detecting Network Instruction Using Suricata IDS

  - Installation Suricata

```sh
add-apt-repository ppa:oisf/suricata-stable -y
apt-get update
apt-get install suricata -y

cd /etc/suricata && mkdir rules && cd

cd /tmp/
curl -LO https://rules.emergingthreats.net/open/suricata-6.0.8/emerging.rules.tar.gz
tar -xvzf emerging.rules.tar.gz
mv rules/*.rules /etc/suricata/rules/
chmod 640 /etc/suricata/rules/*.rules

cd /etc/suricata/rules/
```

- Configuration Suricata

```sh
nano /etc/suricata/suricata.yaml
```

```sh
vars:
  address-groups:
    HOME_NET: "[YOUR_IP]"
    EXTERNAL_NET: "any"

default-rule-path: /etc/suricata/rules

rule-files:
  - "*.rules"

stats:
  enabled: yes

af-packet:
  - interface: enp0s3
    threads: auto               # Utilise tous les CPU dispo
    cluster-id: 99              # Identifiant de groupe de capture
    cluster-type: cluster_flow  # Classe les flux réseau pour mieux gérer
    defrag: yes                 # Réassemble les paquets fragmentés

outputs:
  - eve-log:
      enabled: yes
      filetype: regular
      filename: /var/log/suricata/eve.json
```

- Configuration Wazuh pour Suricata

```sh
nano /var/ossec/etc/ossec.conf
```

- Ajout ceci dans le fichier de configuration de Wazuh Manager

```sh
<ossec_config>
  <localfile>
    <log_format>json</log_format>
    <location>/var/log/suricata/eve.json</location>
  </localfile>
</ossec_config>
```

```sh
sudo systemctl restart suricata
sudo systemctl restart wazuh-agent
```

```sh
cd /var/log/suricata/
tail -f fast.log
```

- Simulation d'attaque et visualise les événements

```sh
# Exécutez
root@attack:~# nmap -sS <IP_VICTIME>
root@attack:~# nmap -sS -T4 -Pn <IP_VICTIME>
root@attack:~# nmap -p 22 --script ssh-brute <IP_VICTIME>
```

- Dans l'interface Wazuh : `Modules > agent01 > Security events > rule.id`

- **Lab #3:** Détection de vulnérabilités

```sh
nano /var/ossec/etc/ossec.conf
```

- Ajout ceci dans le fichier de configuration de Wazuh Manager

```sh
<vulnerability-detection>
  <enabled>yes</enabled>
  <interval>5m</interval>
  <min_full_scan_interval>6h</min_full_scan_interval>
  <run_on_start>yes</run_on_start>
  <alert_if_above>high</alert_if_above>

  <!-- Ubuntu -->
  <provider name="canonical">
    <enabled>yes</enabled>
    <os>focal</os>
    <os>jammy</os>
    <exclude>libreoffice*</exclude>
  </provider>

  <!-- Windows -->
  <provider name="msu">
    <enabled>yes</enabled>
    <update_interval>1h</update_interval>
  </provider>

  <!-- Red Hat (optionnel) -->
  <provider name="redhat">
    <enabled>yes</enabled>
    <os>8</os>
    <os>9</os>
  </provider>
</vulnerability-detection>
```

```sh
service wazuh-manager restart
service wazuh-manager status
```

- Pour vérification que ça fonctionne Sur le Manager

```sh
tail -f /var/ossec/logs/alerts/alerts.log | grep "vulnerability"
```

- Pour vérification que ça fonctionne Sur l'agent (Linux)

```sh
sudo wazuh-control info | grep -i "vulnerability"
```

- Dans l'interface Wazuh : `Modules > agent01 > Vulnerabilities`

- **Lab #4:** Auditd

  - Installation Auditd

```sh
apt install auditd -y
systemctl enable --now auditd
```

- Configuration Auditd

```sh
cd /var/log/audit/ && tail -f audit.log
```

```sh
nano /etc/audit/audit.rules
```

- Ajout ces règles dans /etc/audit/audit.rules

```sh
-a exit,always -F euid=0 -F arch=b64 -S execve -k audit-wazuh-c
-a exit,always -F euid=0 -F arch=b32 -S execve -k audit-wazuh-c
```

- Si nécessaire, configurez : **Management > CDB lists > audit-keys**

```sh
auditctl -R /etc/audit/audit.rules
netstat
```

- Configuration Wazuh pour Auditd

```sh
nano /var/ossec/etc/ossec.conf
```

- Ajout ceci dans le fichier de configuration de Wazuh Manager

```sh
<ossec_config>
  <localfile>
    <log_format>audit</log_format>
    <location>/var/log/audit/audit.log</location>
  </localfile>
</ossec_config>
```

```sh
systemctl restart auditd wazuh-agent
```

- Dans l'interface Wazuh : **Modules > agent01 > Security events**

- **Lab #5:** Detecting and Blocking SSH brute force attacks

  - Configuration Manager pour SSH brute force

```sh
nano /var/ossec/etc/ossec.conf
```

- Ajout ceci dans le fichier de configuration de Wazuh Manager

```sh
<ossec_config>
  <!--Active Response-->
  <active-response>
    <command>firewall-drop</command>
    <location>local</location>
    <rules_id>5763</rules_id>
    <timeout>180</timeout>
  </active-response>

  <active-response>
    <command>host-deny</command>
    <location>local</location>
    <level>10</level>
    <timeout>600</timeout>
</active-response>

</ossec_config>
```

```sh
service wazuh-manager restart
```

- Modifiez : **Management > Rules > Manage rules files > 0095-sshd_rules.xml**

- Configuration Agent pour les réponses actives

```sh
root@wazuh:/# cd /var/ossec/active-response/bin/
root@wazuh:/var/ossec/active-response/bin# ls
default-firewall-drop  firewalld-drop  ipfw          npf            restart.sh
disable-account        host-deny       kaspersky     pf             route-null
firewall-drop          ip-customblock  kaspersky.py  restart-wazuh  wazuh-slack
root@wazuh:/var/ossec/active-response/bin#
```

- Ajout ceci dans le fichier de configuration de Wazuh Agent

![agent](/Wazuh/assets/03.png)

```sh
nano /var/ossec/etc/ossec.conf
```

```sh
<ossec_config>
  <!-- Cluster Configuration (Optional) -->
  <cluster>
    <name>wazuh</name>
    <node_name>node01</node_name>
    <node_type>master</node_type>
    <key>aa093264ef885029653eea20dfcf51ae</key>
    <port>1516</port>
    <bind_addr>0.0.0.0</bind_addr>
    <nodes>
        <node>wazuh.manager</node>
    </nodes>
    <hidden>no</hidden>
    <disabled>yes</disabled>
  </cluster>

  <!-- VirusTotal Integration -->
  <integration>
    <name>virustotal</name>
    <api_key>YOUR_VIRUSTOTAL_API_KEY</api_key> <!-- Replace with your API key -->
    <rule_id>100200,100201</rule_id>
    <alert_format>json</alert_format>
  </integration>

  <!-- Active Response Logging -->
  <localfile>
    <log_format>syslog</log_format>
    <location>/var/ossec/logs/active-responses.log</location>
  </localfile>
</ossec_config>
```

- N'oubliez pas de remplacer YOUR_VIRUSTOTAL_API_KEY par votre clé API VirusTotal.

```sh
service wazuh-manager restart
```

- Dans l'interface Wazuh : `Modules > agent01 > Security events`

#### Pour tester l'attaque par force brute SSH

```sh
hydra -t 4 -l root pass.txt <IP_VICTIME> ssh
```

- **Lab #6:** Detecting Malicious files using virustotal

  - Configuration FIM

```sh
nano /var/ossec/etc/ossec.conf
```

- Ajout ceci dans le fichier de configuration de Wazuh Agent

```sh
# <!-- File integrity monitoring -->
<syscheck>
  <!-- Surveillance renforcée -->
  <directories check_all="yes" realtime="yes" report_changes="yes">/root</directories>
  <directories check_all="yes" realtime="yes" report_changes="yes">/home/user1</directories>

  <!-- Surveillance standard pour /etc (sans report_changes global) -->
  <directories check_all="yes" realtime="yes">/etc</directories>
  <directories check_all="yes" realtime="yes" report_changes="yes">/etc/shadow</directories> <!-- Fichier spécifique -->

  <!-- Surveillance légère pour les binaires système -->
  <directories check_sum="yes" check_owner="yes" check_group="yes">/usr/bin,/usr/sbin</directories>

  <!-- Exclusions -->
  <ignore>/etc/adjtime</ignore>
  <ignore>/etc/resolv.conf</ignore>
  <ignore>/usr/bin/*.log</ignore>
  <ignore type="sregex">\.swp$|\.tmp$</ignore>  <!-- Fichiers temporaires -->
</syscheck>
```

```sh
systemctl restart wazuh-agent
```

- Modification : `Management > Rules > Manage rules files > Edit local_rules.xml`

```sh
<!-- Local rules -->

<!-- Modify it at your will. -->
<!-- Copyright (C) 2015, Wazuh Inc. -->

<!-- Example -->
<group name="local,syslog,sshd,">

  <!--
  Dec 10 01:02:02 host sshd[1234]: Failed none for root from 1.1.1.1 port 1066 ssh2
  -->
  <rule id="100001" level="5">
    <if_sid>5716</if_sid>
    <srcip>1.1.1.1</srcip>
    <description>sshd: authentication failed from IP 1.1.1.1.</description>
    <group>authentication_failed,pci_dss_10.2.4,pci_dss_10.2.5,</group>
  </rule>

  <rule id="100200" level="7">
    <if_sid>550</if_sid>
    <field name="file">/root</field>
    <description>File modified in /root directory.</description>
  </rule>
  <rule id="100201" level="7">
    <if_sid>554</if_sid>
    <field name="file">/root</field>
    <description>File added to /root directory.</description>
  </rule>

</group>
```

- Téléchargement un fichier de test [EICAR](https://www.eicar.org/)

```sh
root@agent:~# curl -Lo /root/eicar.com https://secure.eicar.org/eicar.com && sudo ls -lah /root/eicar.com
```

- Vérification les logs dans l'interface Wazuh : `Modules > Security events`

# Conclusion

- **Wazuh s’impose comme un véritable couteau suisse de la cybersécurité**. En combinant surveillance en temps réel, détection d’intrusions, analyse des fichiers, supervision des journaux système, détection de vulnérabilités et intégration avec des outils tels que Suricata ou VirusTotal, il offre aux administrateurs une capacité de réaction rapide et centralisée face aux menaces.

- À travers ces premiers laboratoires, vous avez exploré les principales fonctionnalités de Wazuh et appris à le déployer pour protéger efficacement des environnements **Linux, Windows** et même cloud. Ce socle vous permettra d’aller plus loin dans la mise en place d’un système de sécurité robuste, adapté à votre infrastructure.
