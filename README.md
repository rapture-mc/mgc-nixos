# NixOS Infrastructure Configuration

Monorepo for Megacorp Industries's NixOS infrastrucure.

Contains:
- NixOS host configurations
- NixOS modules consumed by the NixOS hosts
- NixOS image generators for different platforms
- NixOS overlays for custom nixpkgs patches

## Doco
Nix/NixOS is notorious for terrible documentation so a big emphasis is aimed towards making the documentation for this repository as good as the code itself.

Main documention lives in [./docs](https://github.com/rapture-mc/mgc-nixos/tree/main/docs) and service-specific module documentation can be found in the [./modules/services/(service-name)](https://github.com/rapture-mc/mgc-nixos/tree/main/modules/services) directory.
