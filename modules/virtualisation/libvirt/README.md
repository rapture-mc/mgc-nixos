# Libvirt Module
Libvirt is an API to interface with a Linux kernel running KVM. KVM (and QEMU) enables a Linux host to run virtualised workloads for free.

## Getting started
Setting the following...
```
{
  megacorp = {
    config.networking = {
      enable = true;
      ipv4 = "192.168.0.2";  <-- Change
      interface = "ens0";  <-- Change
      gateway = "192.168.0.1";  <-- Change
      nameservers = [
        "192.168.0.1"  <-- Change
      ];
      bridge.enable = true;
    };

    virtualisation.libvirt.hypervisor = {
      enable = true;
      libvirt-users = [
        "admin"  <-- Change
      ];
    };
  };
}
```
Will:
- Set a static IP and turn the interface into a bridge interface
- Install KVM, QEMU and Libvirt
- Install extra virtualisation packages
- Make your user a member of the libvirt group (required to interact with the Libvirt API)
- Provision the default storage pool on the host

You will then need to reboot your machine to before being able to create virtual machines declartively using this module (terraform for some reason can't see the default pool until).

Once rebooted you will need a "base" QCOW2 image from which new virtual machines will be built from.

The following...
```
{
  megacorp = {
    config.networking = {
      enable = true;
      ipv4 = "192.168.0.2";
      interface = "ens0";
      gateway = "192.168.0.1";
      nameservers = [
        "192.168.0.1"
      ];
      bridge.enable = true;
    };

    virtualisation.libvirt.hypervisor = {
      enable = true;
      libvirt-users = [
        "admin"
      ];
      machines = {
        nixos = {
          os_img_url = "/var/lib/libvirt/images/nixos.qcow2";
          vm_hostname_prefix = "nixos-";
          memory = "8192";
          vcpu = 4;
        };
      };
    };
  };
}
```
Will:
- Create a new virtual machine called "nixos-01"
