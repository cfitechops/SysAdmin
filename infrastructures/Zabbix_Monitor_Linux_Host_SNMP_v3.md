# Zabbix - Surveiller l'hôte Linux via SNMP v3 sur le serveur Zabbix

- **Serveur Zabbix**
  - Adresse IP: `IP X.X.X.X`
- **Hôte Linux**
  - Adresse IP: `IP Y.Y.Y.Y`
- **Identifiants SNMPv3**:
  - Utilisateur : snmpv3user
  - Authentification : SHA avec mot de passe `auth_Password`
  - Chiffrement : AES avec mot de passe `privacy_Password`

#### Installer et configurer SNMP v3 sur un hôte Linux

```sh
zabbix_agent@zabbixagent:~$ hostname -f
```

```sh
zabbix_agent@zabbixagent:~$ sudo apt update && sudo apt install snmpd snmp libsnmp-dev -y
zabbix_agent@zabbixagent:~$ sudo systemctl restart snmpd
zabbix_agent@zabbixagent:~$ sudo systemctl enable snmpd
```

#### Configuration de base `/etc/snmp/snmpd.conf`

```sh
zabbix_agent@zabbixagent:~$ sudo nano /etc/snmp/snmpd.conf
```

```sh
# Configuration minimale
sysLocation "IT Room, Building A"
sysContact "admin@example.com"
agentAddress udp:161,udp6:[::1]:161
rocommunity public 127.0.0.1  # Accès local uniquement (optionnel)

# Désactiver les accès SNMPv1/v2c (sécurité)
disableAuthorization yes
```

#### Enregistrer et quitter le fichier

- Créer un utilisateur SNMPv3 nommé snmpv3user avec un accès en lecture seule

```sh
zabbix_agent@zabbixagent:~$ sudo systemctl stop snmpd
```

#### Créer un utilisateur SNMPv3 et définir les autorisations

- Cette commande crée un utilisateur SNMPv3 nommé snmpv3user avec un accès en lecture seule, en utilisant SHA comme protocole d'authentification avec le mot de passe auth_Password et AES comme protocole de cryptage avec le mot de passe privacy_Password.

```sh
zabbix_agent@zabbixagent:~$ sudo net-snmp-config --create-snmpv3-user -ro -a SHA -A "auth_Password" -x AES -X "privacy_Password" -u snmpv3user
```

#### Maintenant, redémarrez le service SNMP pour appliquer la modification

```sh
zabbix_agent@zabbixagent:~$ sudo systemctl restart snmpd && sudo systemctl enable snmpd

# Vérification locale
zabbix_agent@zabbixagent:~$ sudo snmpwalk -v3 -u snmpv3user -l authPriv -a SHA -A "auth_Password" -x AES -X "privacy_Password" localhost system | head -5
```

#### Si vous avez activé le pare-feu, vous devez autoriser le port 161 à travers le pare-feu

```sh
zabbix_agent@zabbixagent:~$ sudo ufw allow 161/udp
zabbix_agent@zabbixagent:~$ sudo ufw reload
```

# Sur le serveur Zabbix

#### Vérifier la connexion entre le serveur Zabbix et l'hôte Linux via SNMP v3

- Installer SNMP v3 sur le serveur Zabbix

```sh
zabbix_server@zabbixserver:~$ sudo apt install snmpd snmp libsnmp-dev -y
```

- Vérifiez la connexion entre le serveur Zabbix et l'hôte Linux via SNMP v3

```sh
zabbix_server@zabbixserver:~$ snmpwalk -v3 -u snmpv3user -l authPriv -a SHA -A "auth_Password" -x AES -X "privacy_Password" <Y.Y.Y.Y> | head -10
```

#### Notez les mots de passe `SHA`, `AES` les mots de passe et le compte SNMP configurés

- Si le résultat renvoyé est similaire, cela signifie que la connexion est réussie !

```sh
iso.3.6.1.2.1.1.1.0 = STRING: "Linux zabbixagent 6.8.0-60-generic #63-Ubuntu SMP PREEMPT_DYNAMIC Tue Apr 15 19:04:15 UTC 2025 x86_64"
iso.3.6.1.2.1.1.2.0 = OID: iso.3.6.1.4.1.8072.3.2.10
iso.3.6.1.2.1.1.3.0 = Timeticks: (104577) 0:17:25.77
iso.3.6.1.2.1.1.4.0 = STRING: "Your_Email4@gmail.com"
iso.3.6.1.2.1.1.5.0 = STRING: "zabbixagent"
iso.3.6.1.2.1.1.6.0 = STRING: "IT Room"
iso.3.6.1.2.1.1.7.0 = INTEGER: 72
iso.3.6.1.2.1.1.8.0 = Timeticks: (0) 0:00:00.00
iso.3.6.1.2.1.1.9.1.2.1 = OID: iso.3.6.1.6.3.10.3.1.1
iso.3.6.1.2.1.1.9.1.2.2 = OID: iso.3.6.1.6.3.11.3.1.1
```

#### Ajouter un hôte Linux via SNMP v3 sur le serveur Zabbix

![SNMP](/assets/Zabbix_SNMP_17.png)
