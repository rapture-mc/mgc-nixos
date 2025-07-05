{
  nixpkgs,
  vars,
  self,
  pkgs,
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
        (import ./bind.nix {
          inherit pkgs vars;
        })
        (import ./secrets.nix {
          inherit vars;
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
        };

        services.lldap = {
          enable = true;
          fqdn = "mgc-drw-dmc01.${vars.networking.internalDomain}";
          base-dn = "dc=prod,dc=megacorp,dc=industries";
          tls = {
            enable = true;
            cert-file = "/var/lib/nginx/mgc-drw-dmc01.crt";
            cert-key = "/var/lib/nginx/mgc-drw-dmc01.pem";
          };
          ldap-tls = {
            enable = true;
            cert-file = "/var/lib/private/lldap/mgc-drw-dmc01.crt";
            cert-key = "/var/lib/private/lldap/mgc-drw-dmc01.pem";
          };
        };

        virtualisation.libvirt.guest.enable = true;
      };
    }
  ];
}
