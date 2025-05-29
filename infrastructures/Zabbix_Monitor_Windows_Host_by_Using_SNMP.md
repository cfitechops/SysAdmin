# Zabbix - Monitor Windows Host by Using SNMP on Zabbix Server

#### Configure SNMP on Windows

![SNMP](/assets/Zabbix_SNMP_01.png)

![SNMP](/assets/Zabbix_SNMP_02.png)

#### Ensure it's running...

![SNMP](/assets/Zabbix_SNMP_03.png)

#### Tab Agent

- Enter your email and Location and check all

![SNMP](/assets/Zabbix_SNMP_04.png)

#### Tab Security and Add

![SNMP](/assets/Zabbix_SNMP_05.png)

![SNMP](/assets/Zabbix_SNMP_06.png)

#### Accept SNMP packats from any from any host

![SNMP](/assets/Zabbix_SNMP_07.png)

![SNMP](/assets/Zabbix_SNMP_08.png)

#### Restart SNMP service to apply the changes

![SNMP](/assets/Zabbix_SNMP_09.png)

#### Verify IP address on windows

![SNMP](/assets/Zabbix_SNMP_10.png)

#### Verify the connection between Zabbix Server and Windows via SNMP

- Install SNMP Service on Zabbix Server if it's not already installed

```sh
zabbix_server@zabbixserver:~$ sudo apt install snmp -y
```

#### Note replace:

- `win22.barry.ca` = Your Community Name

- `192.168.129.100` = Your Windows Server IP

```sh
zabbix_server@zabbixserver:~$ sudo snmpwalk -v2c -c win22.barry.ca 192.168.129.100
```

#### If the returned result is similar to this. It's OK

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

#### Add Windows Host usin SNMP on Zabbix Server and Create host

![SNMP](/assets/Zabbix_SNMP_11.png)

#### Enter Hostname of Windows Server , add Windows by SNMP

![SNMP](/assets/Zabbix_SNMP_12.png)

##### Templates/Operating systems

![SNMP](/assets/Zabbix_SNMP_13.png)

#### SNMP version: `SNMPv2`

![SNMP](/assets/Zabbix_SNMP_14.png)

#### Tab Macros and Enter your Communuity Name

![SNMP](/assets/Zabbix_SNMP_15.png)

#### Monitor Windows host

![SNMP](/assets/Zabbix_SNMP_16.png)
