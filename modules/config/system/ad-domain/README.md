# Module to join a NixOS machine to an AD environment
Using this module one can integrate a NixOS machine into an Active Directory environment and centralize user management.

In doing so authentication for services such as SSHD and sudo can be offloaded to AD for processing.

You must ensure that the NixOS machine is configured to use the domain controller for DNS. Use the megacorp.config.networking.static-ip.nameservers option to set the DNS server.

## Getting started...
Setting the following...
```
{
  megacorp.config.system.ad-domain = {
    enable = true;
    domain-name = "ad.megacorp.industries";
    netbios-name = "AD";
  };
}
```
Will:
- Install and configure the SSSD daemon
- Install and configure the kerberos client
- Install and configure Samba to interact with SMB

After rebuilding the system the SSSD daemon will fail. This is expected since we haven't joined the AD domain.

Now run:
```console
# "Administrator" or any AD user who is authorized to join machines to a domain
user@host:~$ sudo net ads join -U Administrator
```

And you should see a message returned saying you succesfully joined the domain.

Now restart the SSSD daemon and it shouldn't fail now.
```console
user@host:~$ sudo systemctl restart sssd
```

## Disabling local auth for sudo + sshd
By default the machine still permits local authentication for SSHD and sudo ontop of AD auth. Generally this isn't desirable and instead all authentication should be handled by AD alone.

To only permit AD authentication for SSHD and sudo you can set the following...
```
{
  megacorp.config.system.ad-domain = {
    enable = true;
    domain-name = "ad.megacorp.industries";
    netbios-name = "AD";
    local-auth = {
      sudo = false;
      sshd = false;
    };
  };
}
```
This will lock down sshd and sudo authentication to AD only.
