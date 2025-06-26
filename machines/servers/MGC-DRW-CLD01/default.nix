{
  nixpkgs,
  self,
  vars,
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
        (import ./route53.nix {
          inherit vars;
        })
      ];

      networking.hostName = "MGC-DRW-CLD01";

      system.stateVersion = "25.05";

      environment.systemPackages = [
        pkgs.awscli2
      ];

      megacorp = {
        config = {
          bootloader.enable = true;

          networking.static-ip = {
            enable = true;
            ipv4 = vars.networking.hostsAddr.MGC-DRW-CLD01.eth.ipv4;
            interface = vars.networking.hostsAddr.MGC-DRW-CLD01.eth.name;
            gateway = vars.networking.defaultGateway;
            nameservers = vars.networking.nameServers;
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
