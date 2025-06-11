# Nginx NixOS Module

## Overview
This module deploys an nginx reverse proxy that can be used in conjunction with other NixOS service modules in this same repo. SSL termination is done on this host and HTTP requests forwarded to corresponding application server.

## Deployment
### Deploy using:
```
megacorp.services.nginx = {
  enable = true;
  tls-email = "<email>";
};
```

### Example nginx deployment with external file-browser application server:
```
megacorp.services.nginx = {
  enable = true;
  tls-email = "<email>";
  file-browser = {
    enable = true;
    ipv4 = "<ip-of-file-browser-server>";
    fqdn = "<domain-name-of-file-browser>";
  };
};
```
- "nginx.file-browser.fqdn" should be "file-browser.example.com"
- Ensure DNS A records, port forwards, firewall rules, etc are setup prior to deployment
