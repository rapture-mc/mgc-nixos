# Bookstack Module
This module installs bookstack and all it's components.

Setting the following...
```
megacorp.services.bookstack = {
  enable = true;
  app-key-file = "/run/secrets/bookstack-keyfile"l
}
```
Will:
- Install Bookstack
- install MySQL (MariaDB)
- Install Nginx
- Open port TCP/80
- Configure Bookstack to connect to the MySQL instance
- Configure Nginx to serve Bookstack over http://localhost 
