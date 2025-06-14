# Machine Types Reference

- BST = Bastion Server
> This machine acts as a jump host which has direct access to all the other machines through public key authentication
> All other hosts should be only accessible via the bastion host
> Added benefit of having a centralized administrative entrypoint into the NixOS network.

- HVS = Hypervisor Server
> A physical machine that runs virtualised workloads
> Typically runs the Libvirt/QEMU/KVM stack

- RVP = Reverse Proxy
> A server that directs HTTP/S traffic to other servers
> Exposed to the internet
> Typically runs [Nginx](https://nginx.org/)

- FBR = File Browser Server
> Runs file sharing software
> Typically runs [File Browser](https://filebrowser.org/)

- DGW = Desktop Gateway
> Runs a remote desktop solution
> Typically runs [Apache Guacamole](https://guacamole.apache.org/)

- VLT = Vault Server
> Secrets management solution
> Runs [Hashicorp Vault](https://www.hashicorp.com/en/products/vault)

- DMC = Domain Controller
> Either Windows-based or Linux-based implementation (OpenLDAP + Dnsmasq)

- RST = Restic Server
> Backup solution running [Restic](https://restic.net/)

- LT = Laptop
> For machines that are laptops

- DT = Desktop
> For machines that are desktops
