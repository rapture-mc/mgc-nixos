# File-Browser Module
File Browser provides a file managing interface within a specified directory and it can be used to upload, delete, preview and edit your files. It is a create-your-own-cloud-kind of software where you can just install it on your server, direct it to a path and access your files through a nice web interface.

**NOTE:** The File-Browser project is currently in [maintenace mode](https://github.com/filebrowser/filebrowser/discussions/4906) meaning it has no active maintainers. There is still a large userbase behind it and many forks and contributions but the official maintainer is wanting to pass the responsibility to someone else.

## Getting Started
Setting the following...
```
megacorp.services.file-browser = {
  enable = true;
}
```
Will:
- Install File-Browser using docker compose 
- Install Nginx and listen to requests on localhost and forward them to File-Browser on localhost TCP/8080
- Map port 8080 on the host to port 8080 inside the File-Browser container
- Create the File-Browser file store directory (default is /data/file-browser) with correct permissions

To specify a different data directory...
- Ensure file-browser (UID/GID 1000:1000) has owner/group permissions to the directory first.
```
megacorp.services.file-browser = {
  enable = true;
  data-path = "/var/lib/file-browser";
}
```
And to specify the domain name that File-Browser will listen on...
```
megacorp.services.dnsmasq = {
  enable = true;
  data-path = "/var/lib/file-browser";
  fqdn = "file-browser.example.com";
}
```

## Default Credenials
```
Username: admin
Password: (run "journalctl -u file-browser.service" to check the default randomly generated admin password in the logs)
```

## Accessing HTTP web interface over a network
[See here](https://github.com/rapture-mc/mgc-nixos/tree/main/docs/making-services-accessible-via-network.md)

## Encrypting HTTP with TLS (HTTPS)
[See here](https://github.com/rapture-mc/mgc-nixos/tree/main/modules/_shared/nginx)

