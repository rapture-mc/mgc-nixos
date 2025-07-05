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
      ];

      networking.hostName = "MGC-DRW-GIT01";

      system.stateVersion = "25.05";

      megacorp = {
        config = {
          bootloader.enable = true;

          networking.static-ip = {
            enable = true;
            ipv4 = vars.networking.hostsAddr.MGC-DRW-GIT01.eth.ipv4;
            interface = vars.networking.hostsAddr.MGC-DRW-GIT01.eth.name;
            gateway = vars.networking.defaultGateway;
            nameservers = vars.networking.nameServers;
            lan-domain = vars.networking.internalDomain;
          };
        };

        services = {
          gitea = {
            enable = true;
            logo = true;
            fqdn = vars.networking.hostsAddr.MGC-DRW-GIT01.eth.ipv4;
          };
        };

        virtualisation.libvirt.guest.enable = true;
      };
    }
  ];
}
