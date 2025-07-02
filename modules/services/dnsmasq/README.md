# DNSMasq Module
DNSMasq is a lightweight, open-source service that acts as a DNS forwarder, DHCP server, and TFTP server, primarily for small networks. It's designed to be easy to configure and has a small footprint.

This module however only makes use of the DHCP server feature of DNSMasq. DHCP and TFTP features are not covered.

## Getting Started
Setting the following...
```
megacorp.services.dnsmasq = {
  enable = true;
  hosts = ''
    192.168.1.10 local-server
  '';
}
```
Will:
- Install/configure the DNSMasq service to act as a DHCP server listening on UDP/53
- Create a hosts file /etc/custom-hosts which DNSMasq will use for serving DNS requests

To specify the forwarders (Google's DNS servers are the default)...
```
megacorp.services.dnsmasq = {
  enable = true;
  hosts = ''
    192.168.1.10 local-server
  '';
  forwarders = [
    "1.1.1.1"
    "1.0.0.1"
  ];
}
```
And to specify the domain name that DNSMasq will use.
```
megacorp.services.dnsmasq = {
  enable = true;
  hosts = ''
    192.168.1.10 local-server
  '';
  forwarders = [
    "1.1.1.1"
    "1.0.0.1"
  ];
  domain = "internal.example.com";
}
```
