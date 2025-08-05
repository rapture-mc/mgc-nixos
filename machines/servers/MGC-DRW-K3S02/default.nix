{
  nixpkgs,
  self,
  vars,
  sops-nix,
  ...
}:
nixpkgs.lib.nixosSystem {
  modules = [
    self.nixosModules.default
    sops-nix.nixosModules.sops
    {
      imports = [
        ../../_shared/qemu-hardware-config.nix
        (import ../../_shared/common-config.nix {
          inherit vars;
        })
        # (import ./secrets.nix {
        #   inherit vars;
        # })
      ];

      networking.hostName = "MGC-DRW-K3S02";

      system.stateVersion = "25.05";

      megacorp = {
        config = {
          bootloader.enable = true;

          networking.static-ip = {
            enable = true;
            ipv4 = vars.networking.hostsAddr.MGC-DRW-K3S02.eth.ipv4;
            interface = vars.networking.hostsAddr.MGC-DRW-K3S02.eth.name;
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
          enable = false;
          logo = true;
          role = "agent";
          server-ip = vars.networking.hostsAddr.MGC-DRW-K3M01.eth.ipv4;
          token-file = "/run/secrets/kube-token";
        };
      };
    }
  ];
}
