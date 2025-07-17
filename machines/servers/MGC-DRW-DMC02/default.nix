{
  nixpkgs,
  vars,
  self,
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
        (import ../../_shared/server-config.nix {
          inherit vars;
        })
      ];

      networking.hostName = "MGC-DRW-DMC02";

      system.stateVersion = "25.05";

      megacorp = {
        config = {
          bootloader.enable = true;

          networking.static-ip = {
            enable = true;
            ipv4 = vars.networking.hostsAddr.MGC-DRW-DMC02.eth.ipv4;
            interface = vars.networking.hostsAddr.MGC-DRW-DMC02.eth.name;
            gateway = vars.networking.defaultGateway;
            nameservers = ["127.0.0.1"];
            lan-domain = vars.domains.internalDomain;
          };
        };

        virtualisation.libvirt.guest.enable = true;
      };
    }
  ];
}
