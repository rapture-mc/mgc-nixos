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
        (import ../../_shared/server-config.nix {
          inherit vars;
        })
        (import ./secrets.nix {
          inherit vars;
        })
      ];

      networking.hostName = "MGC-DRW-SEM01";

      system.stateVersion = "25.05";

      networking.hosts = {
        "192.168.1.7" = [ "mgc-drw-dmc01.prod.megacorp.industries" ];
      };

      megacorp = {
        config = {
          bootloader.enable = true;

          networking.static-ip = {
            enable = true;
            ipv4 = vars.networking.hostsAddr.MGC-DRW-SEM01.eth.ipv4;
            interface = vars.networking.hostsAddr.MGC-DRW-SEM01.eth.name;
            gateway = vars.networking.defaultGateway;
            nameservers = ["192.168.1.7"];
            lan-domain = vars.domains.internalDomain;
          };

          users.${vars.adminUser}.extra-groups = [
            "podman"
          ];

          system.ad-domain = {
            enable = true;
            domain-name = vars.domains.internalDomain;
            netbios-name = "PROD";
            local-auth = {
              sudo = false;
            };
          };
        };

        services = {
          semaphore = {
            enable = true;
            fqdn = vars.domains.semaphoreFQDN;
            tls = {
              enable = true;
              cert-file = "/var/lib/nginx/semaphore.crt";
              cert-key = "/var/lib/nginx/semaphore.pem";
            };
            kerberos = {
              enable = true;
              kdc = "mgc-drw-dmc01";
              domain = "prod.megacorp.industries";
            };
          };

          snipe-it = {
            enable = true;
            fqdn = vars.domains.snipe-itFQDN;
            tls = {
              enable = true;
              cert-file = "/var/lib/nginx/snipe-it.crt";
              cert-key = "/var/lib/nginx/snipe-it.pem";
            };
          };

          bloodhound = {
            enable = true;
            fqdn = vars.networking.hostsAddr.MGC-DRW-SEM01.eth.ipv4;
            tls.enable = true;
          };
        };

        virtualisation.libvirt.guest.enable = true;
      };
    }
  ];
}
