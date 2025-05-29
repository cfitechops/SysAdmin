# Zabbix - Monitor Linux Host via SNMP v3 on Zabbix Server

- Zabbix Server
  - IP Address: `IP Address`
- Linux Host
  - IP Address: `IP Address`
  - SNMPv3 User: snmpv3user
  - SHA Password: auth_Password
  - AES Password: privacy_Password

#### Install and Configure SNMP v3 on Linux Host

```sh
zabbix_agent@zabbixagent:~$ hostname -f
```

```sh
zabbix_agent@zabbixagent:~$ sudo apt install snmpd snmp libsnmp-dev -y
zabbix_agent@zabbixagent:~$ sudo systemctl restart snmpd
zabbix_agent@zabbixagent:~$ sudo systemctl enable snmpd
```

#### Open /etc/snmp/snmpd.conf file

```sh
zabbix_agent@zabbixagent:~$ sudo nano /etc/snmp/snmpd.conf
```

```sh
sysLocation    IT Room
sysContact     thiernobarry554@gmail.com

### Comment line 49 and add new content to line 50

#agentaddress  127.0.0.1,[::1]
agentaddress udp:161,udp6:[::1]:161
```

#### Save and exit the file

- Create and SNMPv3 User named snmpv3user with Read-only Access

```sh
zabbix_agent@zabbixagent:~$ sudo systemctl stop snmpd
```

#### Create an SNMPv3 user and set permission

- This command creates an SNMPv3 user named snmpv3user with read-only access, using SHA as the authentication protocol with the password auth_Password, and AES as the encryption protocol with the password privacy_Password.

```sh
zabbix_agent@zabbixagent:~$ sudo net-snmp-config --create-snmpv3-user -ro -a SHA -A auth_Password -x AES -X privacy_Password snmpv3user
```

#### Now, restart the SNMP service to apply the change

```sh
zabbix_agent@zabbixagent:~$ sudo systemctl restart snmpd
zabbix_agent@zabbixagent:~$ sudo systemctl status snmpd
```

#### If you have the firewall enabled, you need to allow port 161 through the firewall

```sh
zabbix_agent@zabbixagent:~$ sudo ufw allow 161
zabbix_agent@zabbixagent:~$ sudo ufw reload
```

# On Zabbix Server

#### Check Connection between Zabbix Server and Linux Host via SNMP v3

- Install SNMP v3 on Zabbix Server

```sh
zabbix_server@zabbixserver:~$ sudo apt install snmpd snmp libsnmp-dev -y
```

- Check the connection between the Zabbix Server and the Linux Host via SNMP v3

```sh
zabbix_server@zabbixserver:~$ snmpwalk -v3 -a SHA -A auth_Password -x AES -X privacy_Password -l authPriv -u snmpv3user 192.168.129.163 | head -10
```

#### Note the `SHA`, `AES` passwords, and the SNMP account configured

- If the returned result is similar, it means the connection is successful!

```sh
iso.3.6.1.2.1.1.1.0 = STRING: "Linux zabbixagent 6.8.0-60-generic #63-Ubuntu SMP PREEMPT_DYNAMIC Tue Apr 15 19:04:15 UTC 2025 x86_64"
iso.3.6.1.2.1.1.2.0 = OID: iso.3.6.1.4.1.8072.3.2.10
iso.3.6.1.2.1.1.3.0 = Timeticks: (104577) 0:17:25.77
iso.3.6.1.2.1.1.4.0 = STRING: "thiernobarry554@gmail.com"
iso.3.6.1.2.1.1.5.0 = STRING: "zabbixagent"
iso.3.6.1.2.1.1.6.0 = STRING: "IT Room"
iso.3.6.1.2.1.1.7.0 = INTEGER: 72
iso.3.6.1.2.1.1.8.0 = Timeticks: (0) 0:00:00.00
iso.3.6.1.2.1.1.9.1.2.1 = OID: iso.3.6.1.6.3.10.3.1.1
iso.3.6.1.2.1.1.9.1.2.2 = OID: iso.3.6.1.6.3.11.3.1.1
```

#### Add Linux Host via SNMP v3 on Zabbix Server

![SNMP](/assets/Zabbix_SNMP_17.png)
