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
        (import ./secrets.nix {
          inherit vars;
        })
      ];

      networking.hostName = "MGC-DRW-APS01";

      system.stateVersion = "25.05";

      megacorp = {
        config = {
          bootloader.enable = true;

          networking.static-ip = {
            enable = true;
            ipv4 = vars.networking.hostsAddr.MGC-DRW-APS01.eth.ipv4;
            interface = vars.networking.hostsAddr.MGC-DRW-APS01.eth.name;
            gateway = vars.networking.defaultGateway;
            nameservers = vars.networking.nameServers;
            lan-domain = vars.domains.internalDomain;
          };
        };

        services = {
          bookstack = {
            enable = true;
            logo = true;
            fqdn = "bookstack.${vars.domains.internalDomain}";
            tls = {
              enable = true;
              cert-file = "/var/lib/nginx/bookstack.crt";
              cert-key = "/var/lib/nginx/bookstack.pem";
            };
          };
        };

        virtualisation.libvirt.guest.enable = true;
      };
    }
  ];
}
