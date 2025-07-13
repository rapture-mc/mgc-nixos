# Libvirt Module
Libvirt is an API to interface with a Linux kernel running KVM. KVM (and QEMU) enables a Linux host to run virtualised workloads for free.

## Getting started
Setting the following...
```
{
  megacorp.virtualisation.libvirt.hypervisor = {
    enable = true;
    libvirt-users = [
      "<your-username>"
    ];
  };
}
```
Will:
- Install KVM, QEMU and Libvirt
- Install extra virtualisation packages
- Make your user a member of the libvirt group (required to interact with the Libvirt API)
