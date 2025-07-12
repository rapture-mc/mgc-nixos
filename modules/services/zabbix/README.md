# Zabbix Module
Zabbix is an open-source, enterprise-level monitoring solution for IT infrastructure. It's designed to monitor various aspects of networks, servers, virtual machines, and cloud services. Zabbix provides a centralized platform for collecting, visualizing, and analyzing data, enabling proactive problem detection and efficient IT management.

## Getting Started
Setting the following...
```
megacorp.services.zabbix.server = {
  enable = true;
}
```
Will:
- Install the Zabbix web and server components
- Install Postgres
- Install Nginx
- Configure the Zabbix server to connect to the Postgres database
- Expose the Zabbix web interface over https://localhost

## Default Credenials
Username: Admin (case-sensitive)

Password: zabbix

## Installing the Zabbix agent
To install the Zabbix agent and connect it to the Zabbix server...
```
megacorp.services.zabbix.agent = {
  enable = true;
  server = "<zabbix-server-ip>";
}
```

## Accessing HTTP web interface over a network
[See here](https://github.com/rapture-mc/mgc-nixos/tree/main/docs/making-services-accessible-via-network.md)

## Encrypting HTTP with TLS (HTTPS)
[See here](https://github.com/rapture-mc/mgc-nixos/tree/main/modules/_shared/nginx)

## Additional Notes
