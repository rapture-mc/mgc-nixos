# Semaphore NixOS Module

## Overview
This module deploys [Semaphore](https://semaphoreui.com/) in a docker compose stack using [Arion](https://github.com/hercules-ci/arion) since no nixpkgs module exists for deploying Semaphore. Arion is used for language consistency and to utilize the NixOS module system.

## Features
- Kerberos Support (for Windows AD authentication integration)
- Easy docker container administration using [Lazydocker](https://github.com/jesseduffield/lazydocker)
- Automatic TLS reverse proxy support

## Deployment

### Secrets (use sops-nix)
The following Secrets must exist at the following locations prior to deployment:
```
1. /run/secrets/postgres-password                  <-- Password for the postgres database
2. /run/secrets/semaphore-db-pass                  <-- Should be the same as /run/secrets/postgres-password
3. /run/secrets/semaphore-access-key-encryption    <-- Access key for semaphore (generate using "head -c32 /dev/urandom | base64")
```

These files will then be mounted by docker as environment variables which in turn will contain the necessary Semaphore/Postgres secrets.

The contents of the secret file should follow docker environment variable syntax like so:

```
file: /run/secrets/postgres-password

POSTGRES_PASSWORD=<example-password>
```

### Deploy using:
```
megacorp.services.semaphore = {
  enable = true;
  fqdn = "<semaphore-domain-name>";
};
```
- This will deploy 2x containers (1x for semaphore and 1x for postgres) with Nginx serving as a reverse proxy on the same host. Service will fail if Lets encrypt can't obtain a SSL certificate for the host defined in "semaphore.fqdn" so ensure the necssary DNS, port forwards and firewall rules are setup prior.
- Postgres data is stored in a docker volume

### Activate Kerberos authentication using:
```
megacorp.services.semaphore = {
  enable = true;
  kerberos = {
    enable = true;
    kdc = "<domain-controller-hostname>";
    domain = "<domain-name>";
  };
};
```
