# Adding NixOS Machines
All machines NixOS configurations are stored in the machines/ directory and organized into 3x categories:

### Hypervisors
- Physical hosts
- Hosts that act as hypervisors which run virtualised instances of other machines (predominantly NixOS)
- Virtualised instances are defined in Nix code using the megacorp.virtualisation.libvirt.declerative option

### Servers
- Predominantly virtual machines running NixOS
- Each VM generally serves a distinct purpose (e.g. running a service or serves as a bastion host)

### Workstations
- NixOS machines that act as desktop workstations

## Naming machines
Machines are named with the following convention:
[org-shortcode]-<machine-location>-<machine-purpose><machine-instance>

Example: MGC-DRW-HVS01

Where:
- <org-shortcode> = The organinational shortcode that the machine belongs to. E.g MGC for "Megacorp Industries Corporation".
- <machine-location> = The physical location of the machine. E.g DRW for Darwin. **NOTE:** For workstations the location field is omitted.
- <machine-purpose> = The purpose of the machine. E.g HVS for hypervisor (see [this reference](https://github.com/rapture-mc/mgc-nixos/docs/machine-types.md) for list of types).
- <machine-instance> = Numbered instance of the machine type.

## Steps to add a new machine

The following outlines the process to add a new NixOS machine to the flake. In this case we are adding a new physical hypervisor called MGC-DRW-HVS05.

1. Add the new instance as a function attribute to the machines/default.nix file in alphabetical order:
```
{importMachineConfig, ... }: {
  # other existing machines...

  MGC-DRW-HVS05 = importMachineConfig "hypervisors" "MGC-DRW-HVS05";  # This line declares a new hypervisor
};
```

2. It's easiest to just make a copy of an existing machine directory and make the necessary modifications like so:
> cp -r machines/hypervisors/MGC-DRW-HVS01 machines/hypervisors/MGC-DRW-HVS05
> vim machines/hypervisors/MGC-DRW-HVS05/default.nix

The above commands (if run from the top level directory of the repo) will make a copy of an existing hypervisor config under the new machine name.
We then edit the default.nix file which contains the primary NixOS configuration and modify accordingly.

3. Update the hardware-config.nix file. Ensure you replace the existing hardware config file with the actual hardware config file of the new machine.
> nixos-generate-config

The above command will scan the hardware and create a Nix file in /etc/nixos/hardware-configuration.nix.
You will need to copy this file to the new machine's config directory and rename it to hardware-config.nix.

**NOTE:** If you're adding a virtual machine the hardware config will be identical to other VMs of the same kind (unless you have defined extra parameters in the VM such as more disks).

4. Add necessary variables to vars directory.

This step will depend on the situation but likely you will need to add networking variables to vars/networking.nix.
Then ensure that the variables match what's defined in the machines config.nix file.
