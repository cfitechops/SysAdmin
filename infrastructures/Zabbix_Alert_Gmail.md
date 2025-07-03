# Zabbix Alertes de notifications utilisant Gmail

- Configurer Zabbix pour envoyer des **alertes par e-mail via Gmail**, par exemple lorsqu’un **site web est indisponible** ou qu’un **trigger** est activé.

#### Activer la validation en deux étapes sur ton compte Gmail

- Va sur [https://myaccount.google.com](https://myaccount.google.com)

- Active **la validation en 2 étapes**

- Puis clique sur **"Mots de passe des applications"**

![gmail](/assets/Zabbix_alert_00.png)

#### Générer un mot de passe d'application

- Choisir une application : "**Autre**" → **Zabbix**

- Copier le mot de passe à usage unique généré par Google

- Ce mot remplace ton mot de passe habituel dans Zabbix

![gmail](/assets/Zabbix_alert_01.png)

#### Ne pas fermer la fenêtre avant d’avoir copié le mot de passe.

![gmail](/assets/Zabbix_alert_02.png)

#### Configuration du Media type “Gmail” dans Zabbix

- Interface Zabbix : `Administration -> Media types -> Create media type`

![gmail](/assets/Zabbix_alert_03.png)

![gmail](/assets/Zabbix_alert_04.png)

![gmail](/assets/Zabbix_alert_05.png)

![gmail](/assets/Zabbix_alert_06.png)

![gmail](/assets/Zabbix_alert_07.png)

#### Associer l’e-mail à un utilisateur

- `Administration → Users → ton_utilisateur → Media`

- Type : Email

- Send to : ton adresse Gmail

- Severity : cocher les niveaux d’alerte souhaités (Warning, High, Disaster…)

- Active : ✔️

![gmail](/assets/Zabbix_alert_08.png)

![gmail](/assets/Zabbix_alert_09.png)

![gmail](/assets/Zabbix_alert_10.png)

![gmail](/assets/Zabbix_alert_11.png)

#### Test : Simuler une panne

```sh
sudo systemctl stop nginx
```

- Le site devient indisponible

- Le trigger est activé

- Zabbix envoie une alerte → **Vérifie ta boîte Gmail**

![gmail](/assets/Zabbix_alert_12.png)

```sh
sudo systemctl start nginx
```

- Le problème disparaît

- Zabbix peut envoyer une alerte de **"Recovery"**

![gmail](/assets/Zabbix_alert_13.png)
