# Gitea Module
Gitea is a free and open-source, self-hosted Git service, similar to GitHub, GitLab, or Bitbucket, but designed for easy installation and low resource consumption. It provides a platform for code hosting, version control, and collaboration features like code review and issue tracking

## Getting Started
Setting the following...
```
megacorp.services.gitea = {
  enable = true;
}
```
Will:
- Install the Gitea service
- Install PostgreSQL and initialize a gitea database
- Install/configure Nginx to proxy requests to the Gitea service
- Connect Gitea to the PostgreSQL database
- Make Gitea available locally over http://localhost

## Default Credenials
Gitea prompts you to create the first admin user upon successful installation.

## Accessing HTTP web interface over a network
[See here](https://github.com/rapture-mc/mgc-nixos/tree/main/docs/making-services-accessible-via-network.md)

## Encrypting HTTP with TLS (HTTPS)
[See here](https://github.com/rapture-mc/mgc-nixos/tree/main/modules/_shared/nginx)
