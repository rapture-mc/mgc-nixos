{
  nixpkgs,
  vars,
  self,
  pkgs,
  ...
}:

nixpkgs.lib.nixosSystem {
  modules = [
    self.nixosModules.default
    {
      imports = [
        ../../_shared/qemu-hardware-config.nix
        (import ../../_shared/common-config.nix {
          inherit vars;
        })
        (import ./bind.nix {
          inherit pkgs vars;
        })
      ];

      networking.hostName = "MGC-DRW-DMC01";

      system.stateVersion = "24.11";
      megacorp = {
        config = {
          bootloader.enable = true;

          networking.static-ip = {
            enable = true;
            ipv4 = vars.networking.hostsAddr.MGC-DRW-DMC01.eth.ipv4;
            interface = vars.networking.hostsAddr.MGC-DRW-DMC01.eth.name;
            gateway = vars.networking.defaultGateway;
            nameservers = ["127.0.0.1"];
            lan-domain = vars.networking.internalDomain;
          };

          openssh = {
            enable = true;
            authorized-ssh-keys = vars.keys.bastionPubKey;
          };
        };

        virtualisation.libvirt.guest.enable = true;
      };
    }
  ];
}
