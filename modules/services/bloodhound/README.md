# Bloodhound Module
BloodHound is an open-source tool that uses graph theory to analyze and visualize relationships within Active Directory (AD) environments. It helps identify potential attack paths, privilege escalation opportunities, and lateral movement possibilities, making it valuable for both red teams (offensive security) and blue teams (defensive security). BloodHound is often used in conjunction with SharpHound, a data collector that gathers information about the AD environment

## Pre-Requistes: Secrets (use sops-nix)
The following Secrets must exist at the following locations prior to deployment:
```
1. /run/secrets/postgres-password      <-- The password for the Postgres database
2. /run/secrets/neo4j-auth             <-- The username/password value for the Neo4j database
3. /run/secrets/bhe-neo4j-connection   <-- The Neo4j connection URL containing the username/password for the Neo4j database
4. /run/secrets/bhe-database-secret    <-- The password for the Postgres database (same value as /run/secrets/postgres-password)
```

These files will then be mounted by docker as environment variables which in turn will contain the necessary Semaphore/Postgres secrets.

The contents of the secret file should follow docker environment variable syntax like so:

```
file: /run/secrets/postgres-password
POSTGRES_PASSWORD=<example-password>

file: /run/secrets/neo4j-auth
NEO4J_AUTH=<neo4j-username>/<neo4j-password>

file: /run/secrets/bhe-neo4j-connection
bhe_neo4j_connection=neo4j://<neo4j-username>:<neo4j-password>@neo4j:7687/

file: /run/secrets/bhe-database-secret
bhe_database_secret=<example-password>
```


## Getting Started
Setting the following...
```
megacorp.services.bloodhound = {
  enable = true;
}
```
Will:
- Install Docker and Nginx
- Launch 3 docker containers that compose theh bloodhound application (Bloodhound, Neo4j, Postgres)
- Create 2 docker volumes for persisting Neo4j and Postgres stateful data
- Expose Bloodhound over http://localhost

## Default Credenials
**Username**: admin

**Password**: Run "docker logs bloodhound-bloodhound-1" and find the default password there

## Accessing HTTP web interface over a network
[See here](https://github.com/rapture-mc/mgc-nixos/tree/main/docs/making-services-accessible-via-network.md)

## Encrypting HTTP with TLS (HTTPS)
[See here](https://github.com/rapture-mc/mgc-nixos/tree/main/modules/_shared/nginx)

## Additional Notes
