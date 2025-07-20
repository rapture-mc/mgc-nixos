# OpenSSH Module
This module is an opinionated implementation of the OpenSSH NixOS module.

It enables and configures an OpenSSH daemon to be secure by default.

## Getting started
Setting the following...
```
{
  megacorp.config.openssh = {
    enable = true;
  };
}
```
Will:
- Install and start the SSHD service
- Opens port TCP/22
- Only allows members of the wheel group to connect to the SSHD service 
- Disallows root to connect to the SSHD service 
- Only permit public key authentication (disables password based authentication)

However defining this config alone doesn't currently permit anyone to connect to the daemon. To permit a client to connect to the server the clients public key must be trusted by a user located on the server.

We can use the megacorp.config.users.<name> option to define a user on the server as well as an authorized SSH key so you can connect to the daemon as that user.

To allow an SSH key to connect the the daemon as "megaman"...
```
{
  megacorp.config = {
    openssh = {
      enable = true;
    };
    
    users.megaman = {
      sudo = true;
      authorized-ssh-keys = [
        "<public-ssh-key>"
      ];
    };
  };
}
```
This will allow anyone who has the corresponding SSH private key to connect to the daemon as the megaman user.

## Allowing non-root AD users to connect to the SSHD service
If using the megacorp.config.system.ad-domain option you will not be able to connect to the daemon unless you are a member of "wheel" (either locally or in the corresponding AD domain). To allow additional users to connect to the daemon set the "allowed-groups" option.
```
{
  users.groups.allowed-ssh-users.members = [
    "megaman"
  ];

  megacorp.config = {
    openssh = {
      enable = true;
      allowed-groups = [
        "allowed-ssh-users"
      ];
    };
    
    users.megaman = {
      authorized-ssh-keys = [
        "<public-ssh-key>"
      ];

      extra-groups = [
        "allowed-ssh-users"
      ];
    };
  };
}
```

The above config will create a new group "allowed-ssh-users" with "megaman" as a member and permit members of the group to connect to the daemon. Note public key authentication is still only permitted (no password authentication allowed).
