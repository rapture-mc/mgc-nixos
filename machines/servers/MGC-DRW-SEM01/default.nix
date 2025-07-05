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

      networking.hostName = "MGC-DRW-SEM01";

      system.stateVersion = "25.05";

      megacorp = {
        config = {
          bootloader.enable = true;

          networking.static-ip = {
            enable = true;
            ipv4 = vars.networking.hostsAddr.MGC-DRW-SEM01.eth.ipv4;
            interface = vars.networking.hostsAddr.MGC-DRW-SEM01.eth.name;
            gateway = vars.networking.defaultGateway;
            nameservers = vars.networking.nameServers;
            lan-domain = vars.networking.internalDomain;
          };
        };

        services = {
          semaphore = {
            enable = true;
            fqdn = vars.semaphoreFQDN;
            tls = {
              enable = true;
              cert-file = "/var/lib/nginx/mgc-drw-sem01.crt";
              cert-key = "/var/lib/nginx/mgc-drw-sem01.pem";
            };
          };

          snipe-it = {
            enable = true;
            fqdn = vars.snipe-itFQDN;
            tls = {
              enable = true;
              cert-file = "/var/lib/nginx/snipe-it.crt";
              cert-key = "/var/lib/nginx/snipe-it.pem";
            };
          };
        };

        virtualisation.libvirt.guest.enable = true;
      };
    }
  ];
}
