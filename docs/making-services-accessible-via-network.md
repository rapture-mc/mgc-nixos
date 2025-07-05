# Making services accessible via network

If a service module is accessed over HTTP there will always be a **fqdn** option which controls whether the service is accessible locally (default) or over a network. This is implemented using Nginx which will only respond to HTTP requests if the domain name (or IP) matches what's set under the **fqdn** option of that service.

For instance, this bookstack configuration will have the default fqdn value of "localhost" so it will only be accessible from the same machine since Nginx will only respond to requests addressed to localhost (navigating to http://localhost from another machine will direct the request to the other machines http://localhost not the bookstack servers http://localhost).

**Note:** Port TCP/80 will be opened regardless if FQDN is set or not. This may or may not be a security concern. In the majority of cases it's not since Nginx will only respond to requests its explictly configured to answer to.
```
megacorp.services.bookstack = {
  enable = true;
}
```
To make it accessible over the network via it's IP...
```
megacorp.services.bookstack = {
  enable = true;
  fqdn = "192.168.1.10";
}
```
Or via an internally resolveable domain name...
```
megacorp.services.bookstack = {
  enable = true;
  fqdn = "bookstack.local";
}
```
Or via a publicly resolveable domain name...
- Domain "example.com" must have the approriate A/CNAME DNS record pointing to your bookstack servers IP
- This will also be accessed over unencrypted HTTP. For TLS configuration [see this doco](https://github.com/rapture-mc/mgc-nixos/tree/main/modules/_shared/nginx).
```
megacorp.services.bookstack = {
  enable = true;
  fqdn = "example.com";
}
```
