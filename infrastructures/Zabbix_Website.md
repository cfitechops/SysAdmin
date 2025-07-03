# Surveillance de sites Web et d'applications avec le serveur Zabbix

#### Objectif :

- Mettre en place la surveillance d’un site Web ou d’une application hébergée sur un serveur à l’aide de Zabbix.

#### Configuration :

- Le site Web est déjà configuré et l’application est installée sur le serveur. Zabbix est utilisé pour superviser l’état et les performances de ces services.

#### Question : Quel est le statut de ce site Web ?

- Pour connaître le statut, Zabbix envoie des requêtes HTTP/HTTPS vers le site Web.

  - Si le site répond correctement avec un code HTTP 200 (OK), il est **disponible**.

  - Si Zabbix reçoit un **message d’erreur** (par exemple 500, 404, timeout…), cela signifie que le site a un **problème**.

#### Pourquoi a-t-on besoin de cette surveillance ?

- Pour **assurer la disponibilité** du site web à tout moment.

- Pour être **alerté automatiquement** en cas d'erreurs, d’indisponibilité ou de ralentissement.

- Pour **diagnostiquer rapidement** les incidents.

- Pour améliorer la **qualité de service** offerte aux utilisateurs.

#### Et si nous recevons un message d'erreur malgré le succès annoncé ?

- Cela signifie probablement que :

  - Le **frontend (interface utilisateur)** répond, mais le **backend (application, base de données, etc.)** a un problème.

  - L'application retourne une page avec un contenu, mais qui contient un **texte d’erreur** (exemple : "Erreur interne", "Service indisponible").

  - Ou que la réponse HTTP est correcte, mais Zabbix détecte une **anomalie dans le contenu** (grâce à une vérification de mot-clé par exemple).

#### Par exemple,

- Vous êtes connecté à la machine **Agent01**.

- Un site Web est hébergé localement sur cette machine (ou accessible depuis celle-ci).

- Vous souhaitez surveiller ce site avec **Zabbix**, via l’interface ou via une configuration personnalisée.

#### Dans l’interface Zabbix :

- Allez dans `Configuration → Hosts`

- Cliquez sur l’hôte `Agent01`

- Allez dans l’onglet `Web scenarios`

![website](/assets/Zabbix_Website_01.png)

#### Créer un scénario de surveillance HTTP dans Zabbix pour tester automatiquement l’accès à un site web hébergé sur `Agent01`.

- Cliquez sur `Create web scenario`

![website](/assets/Zabbix_Website_02.png)

#### Ajouter un `step` (étape) :

- Cliquez sur **Add** puis remplissez

![website](/assets/Zabbix_Website_03.png)

![website](/assets/Zabbix_Website_04.png)

- Cliquez sur **Add**.

![website](/assets/Zabbix_Website_05.png)

![website](/assets/Zabbix_Website_06.png)

- Cliquez sur **Add** pour enregistrer le scénario complet.

![website](/assets/Zabbix_Website_07.png)

#### Résultat attendu

- Zabbix exécutera cette requête HTTP toutes les minutes.

- Il vérifiera que le code HTTP est **200**.

- Il vérifiera que la réponse contient le mot **Bienvenue**.

- Si l’une des conditions échoue → une **alerte** peut être déclenchée (si un trigger est ajouté).

![website](/assets/Zabbix_Website_08.png)

#### Créer un Trigger

- Allez dans l’onglet **Triggers** de l’hôte **Agent01**

- Cliquez sur **Create trigger**

```sh
last(/agent01/web.test.fail[Media_Library],#1)>0
```

- | **Severity** | `High (ou Warning)` |

![website](/assets/Zabbix_Website_09.png)

- Cliquez sur **Add**

![website](/assets/Zabbix_Website_10.png)

![website](/assets/Zabbix_Website_11.png)

- Arrêt du serveur Web : `sudo systemctl stop nginx`

```sh
sudo systemctl stop nginx
```

![website](/assets/Zabbix_Website_12.png)

![website](/assets/Zabbix_Website_13.png)

![website](/assets/Zabbix_Website_14.png)

- Reprise du service : `sudo systemctl start nginx`

```sh
sudo systemctl start nginx
```

![website](/assets/Zabbix_Website_15.png)

- **Remarque** Zabbix affiche l’erreur → envoie une alerte → puis le problème disparaît une fois le service relancé.
