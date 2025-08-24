# Tailscale/Headscale Module
Tailscale is a service that creates secure, private, and easy-to-manage private networks (tailnets) for connecting devices and services anywhere, using a mesh VPN built on the open-source WireGuard protocol.

## Pre-Requistes: DNS A Records
You must have a DNS A record already configured that points to the server which will run the headscale server.

E.g. tailscale.example.com must resolve to 1.2.3.4 where 1.2.3.4 is the public IP of your headscale server.

## Getting Started - Headscale Server

### Installing the Headscale server
Setting the following...
```
megacorp.services.tailscale.server = {
  enable = true;
  tls-email = "acme@example.com";
  server-url = "tailscale.example.com";
  base-domain = "example.net";
}
```
Will:
- Install the Headscale control plane software
- Install Nginx as a reverse proxy for Headscale with TLS certificates

### Creating the first namespace
```
# The following command will create a namespace which our nodes can later join. "Prod" will be the resulting namespace in this example.
sudo headscale namespaces create prod
```

## Getting Started - Tailnet Client

### Installing the Tailscale client software 
Setting the following...
```
megacorp.services.tailscale.client.enable = true;
```
Will:
- Install the Tailscale client software
- Configure the tailscale network interface
- Open UDP port 41641 for tailnet traffic

### Joining a Tailscale client to your Tailnet network
```
# The following command will output a link with instructions to add the client to the "prod" namespace.
sudo tailscale up --login-server tailscale.example.com
```
