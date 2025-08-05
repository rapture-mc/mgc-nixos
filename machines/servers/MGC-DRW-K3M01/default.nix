{
  nixpkgs,
  self,
  vars,
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

      networking.hostName = "MGC-DRW-K3M01";

      system.stateVersion = "25.05";

      networking.firewall.allowedTCPPorts = [
        80
      ];

      megacorp = {
        config = {
          bootloader.enable = true;

          networking.static-ip = {
            enable = true;
            ipv4 = vars.networking.hostsAddr.MGC-DRW-K3M01.eth.ipv4;
            interface = vars.networking.hostsAddr.MGC-DRW-K3M01.eth.name;
            gateway = vars.networking.defaultGateway;
            nameservers = vars.networking.nameServers;
            lan-domain = vars.domains.internalDomain;
          };

          system.ad-domain = {
            enable = true;
            domain-name = vars.domains.internalDomain;
            netbios-name = "PROD";
            local-auth = {
              login = false;
              sudo = false;
              sshd = false;
              xrdp = false;
            };
          };
        };

        services.k3s = {
          enable = true;
          logo = true;
          cluster-init = true;
        };
      };
    }
  ];
}
