# Shared Nginx Module
This module is used by other modules to secure HTTP applications served by NGINX using TLS.

Modules using this module:
- [Bookstack](https://github.com/rapture-mc/mgc-nixos/tree/main/modules/services/bookstack)
- [Gitea](https://github.com/rapture-mc/mgc-nixos/tree/main/modules/services/gitea)
- [File Browser](https://github.com/rapture-mc/mgc-nixos/tree/main/modules/services/file-browser)
- [Grafana](https://github.com/rapture-mc/mgc-nixos/tree/main/modules/services/grafana)
- [Guacamole](https://github.com/rapture-mc/mgc-nixos/tree/main/modules/services/guacamole)
- [LLDAP](https://github.com/rapture-mc/mgc-nixos/tree/main/modules/services/lldap)
- [Netbox](https://github.com/rapture-mc/mgc-nixos/tree/main/modules/services/netbox)
- [Nextcloud](https://github.com/rapture-mc/mgc-nixos/tree/main/modules/services/nextcloud)
- [Semaphore](https://github.com/rapture-mc/mgc-nixos/tree/main/modules/services/semaphore)
- [Snipe-IT](https://github.com/rapture-mc/mgc-nixos/tree/main/modules/services/snipe-it)
- [Zabbix](https://github.com/rapture-mc/mgc-nixos/tree/main/modules/services/zabbix)

# Getting Started
For example, to enable TLS over HTTP for the Bookstack application...
```
megacorp.services.bookstack = {
  enable = true;
  app-key-file = "/run/secrets/bookstack-keyfile";
  fqdn = "bookstack.local";
  tls = {
    enable = true;
  };
}
```
This will redirect all HTTP requests to HTTPS and attempt to generated signed certificates from Let's Encrypt servers. For this ports 80/443 on the bookstack server must be accessible to the internet either via port forwarding or directly exposed to the internet. If these conditions aren't met self-signed certificates will be created instead.

A custom TLS certificate can be used by specifying the cert + key file like so...
```
megacorp.services.bookstack = {
  enable = true;
  app-key-file = "/run/secrets/bookstack-keyfile";
  fqdn = "bookstack.local";
  tls = {
    enable = true;
    cert-file = "/var/lib/nginx/bookstack.crt";
    cert-key = "/var/lib/nginx/bookstack.key";
  };
}
```
And ensure the directory housing the certificates has permissions like so...
```
chown nginx:nginx /var/lib/nginx
chown nginx:nginx /var/lib/nginx/*
chmod 755 /var/lib/nginx
chmod 600 /var/lib/nginx/*
```
