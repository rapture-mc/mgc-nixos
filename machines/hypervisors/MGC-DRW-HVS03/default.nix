{
  nixpkgs,
  pkgs,
  self,
  vars,
  ...
}:
nixpkgs.lib.nixosSystem {
  modules = [
    self.nixosModules.default
    {
      imports = [
        ./hardware-config.nix
        (import ../../_shared/common-config.nix {
          inherit vars;
        })
        (import ../../_shared/server-config.nix {
          inherit vars;
        })
      ];

      networking.hostName = "MGC-DRW-HVS03";

      system.stateVersion = "24.05";

      environment.systemPackages = with pkgs; [
        devenv
        direnv
        hugo
      ];

      megacorp = {
        config = {
          bootloader.enable = true;

          networking = {
            static-ip = {
              enable = true;
              ipv4 = vars.networking.hostsAddr.MGC-DRW-HVS03.eth.ipv4;
              interface = vars.networking.hostsAddr.MGC-DRW-HVS03.eth.name;
              gateway = vars.networking.defaultGateway;
              nameservers = vars.networking.nameServers;
              lan-domain = vars.networking.internalDomain;
            };
          };

          desktop = {
            enable = true;
            xrdp = true;
          };
        };

        virtualisation.whonix.enable = true;
      };
    }
  ];
}
