# Zabbix - Surveiller l'hôte Windows via SNMP sur le serveur Zabbix

#### Configurer SNMP sous Windows

![SNMP](/assets/Zabbix_SNMP_01.png)

![SNMP](/assets/Zabbix_SNMP_02.png)

#### Assurez-vous qu'il fonctionne...

![SNMP](/assets/Zabbix_SNMP_03.png)

#### Agent d'onglets

- Entrez votre e-mail et votre emplacement et cochez tout

![SNMP](/assets/Zabbix_SNMP_04.png)

#### Onglet Sécurité et Ajouter

![SNMP](/assets/Zabbix_SNMP_05.png)

![SNMP](/assets/Zabbix_SNMP_06.png)

#### Accepter les paquets SNMP de n'importe quel hôte

![SNMP](/assets/Zabbix_SNMP_07.png)

![SNMP](/assets/Zabbix_SNMP_08.png)

#### Redémarrez le service SNMP pour appliquer les modifications

![SNMP](/assets/Zabbix_SNMP_09.png)

#### Vérifier l'adresse IP sous Windows

![SNMP](/assets/Zabbix_SNMP_10.png)

#### Vérifier la connexion entre le serveur Zabbix et Windows via SNMP

- Installez le service SNMP sur le serveur Zabbix s'il n'est pas déjà installé

```sh
zabbix_server@zabbixserver:~$ sudo apt install snmp -y
```

#### Remarque :

- `win22.barry.ca` = Votre nom de communauté

- `192.168.129.100` = Votre adresse IP de serveur Windows

```sh
zabbix_server@zabbixserver:~$ sudo snmpwalk -v2c -c win22.barry.ca 192.168.129.100
```

#### Si le résultat renvoyé est similaire à celui-ci, c'est OK.

```sh
iso.3.6.1.2.1.55.1.11.1.4.16.255.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.1 = INTEGER: 1
iso.3.6.1.2.1.55.1.11.1.5.16.255.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.1 = Hex-STRING: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
iso.3.6.1.2.1.55.1.11.1.6.16.255.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.1 = INTEGER: 3
iso.3.6.1.2.1.55.1.11.1.7.16.255.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.1 = INTEGER: 2
iso.3.6.1.2.1.55.1.11.1.8.16.255.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.1 = INTEGER: 0
iso.3.6.1.2.1.55.1.11.1.9.16.255.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.1 = Gauge32: 0
iso.3.6.1.2.1.55.1.11.1.10.16.255.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.1 = Gauge32: 0
iso.3.6.1.2.1.55.1.11.1.11.16.255.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.1 = Gauge32: 256
iso.3.6.1.2.1.55.1.11.1.12.16.255.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.1 = Gauge32: 0
iso.3.6.1.2.1.55.1.11.1.13.16.255.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.1 = OID: ccitt.0
iso.3.6.1.2.1.55.1.11.1.14.16.255.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.1 = INTEGER: 1
iso.3.6.1.2.1.55.1.12.1.2.1.16.255.2.0.0.0.0.0.0.0.0.0.0.0.0.0.12 = ""
iso.3.6.1.2.1.55.1.12.1.2.1.16.255.2.0.0.0.0.0.0.0.0.0.0.0.0.0.22 = ""
iso.3.6.1.2.1.55.1.12.1.3.1.16.255.2.0.0.0.0.0.0.0.0.0.0.0.0.0.12 = INTEGER: 3
iso.3.6.1.2.1.55.1.12.1.3.1.16.255.2.0.0.0.0.0.0.0.0.0.0.0.0.0.22 = INTEGER: 3
iso.3.6.1.2.1.55.1.12.1.4.1.16.255.2.0.0.0.0.0.0.0.0.0.0.0.0.0.12 = INTEGER: 1
iso.3.6.1.2.1.55.1.12.1.4.1.16.255.2.0.0.0.0.0.0.0.0.0.0.0.0.0.22 = INTEGER: 1
iso.3.6.1.2.1.55.1.12.1.5.1.16.255.2.0.0.0.0.0.0.0.0.0.0.0.0.0.12 = Timeticks: (0) 0:00:00.00
iso.3.6.1.2.1.55.1.12.1.5.1.16.255.2.0.0.0.0.0.0.0.0.0.0.0.0.0.22 = Timeticks: (0) 0:00:00.00
iso.3.6.1.2.1.55.1.12.1.6.1.16.255.2.0.0.0.0.0.0.0.0.0.0.0.0.0.12 = INTEGER: 1
iso.3.6.1.2.1.55.1.12.1.6.1.16.255.2.0.0.0.0.0.0.0.0.0.0.0.0.0.22 = INTEGER: 1
```

#### Ajouter un hôte Windows à l'aide de SNMP sur le serveur Zabbix et créer un hôte

![SNMP](/assets/Zabbix_SNMP_11.png)

#### Entrez le nom d'hôte du serveur Windows, ajoutez Windows via SNMP

![SNMP](/assets/Zabbix_SNMP_12.png)

##### Modèles/Systèmes d'exploitation

![SNMP](/assets/Zabbix_SNMP_13.png)

#### Version SNMP : `SNMPv2`

![SNMP](/assets/Zabbix_SNMP_14.png)

#### Onglets `Macros` et saisissez le nom de votre communauté

![SNMP](/assets/Zabbix_SNMP_15.png)

#### Surveiller l'hôte Windows

![SNMP](/assets/Zabbix_SNMP_16.png)
