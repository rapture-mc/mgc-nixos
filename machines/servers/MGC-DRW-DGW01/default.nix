{
  nixpkgs,
  vars,
  self,
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

      networking.hostName = "MGC-DRW-DGW01";

      system.stateVersion = "24.11";

      megacorp = {
        config = {
          bootloader.enable = true;

          networking.static-ip = {
            enable = true;
            ipv4 = vars.networking.hostsAddr.MGC-DRW-DGW01.eth.ipv4;
            interface = vars.networking.hostsAddr.MGC-DRW-DGW01.eth.name;
            gateway = vars.networking.defaultGateway;
            nameservers = vars.networking.nameServers;
            lan-domain = vars.domains.internalDomain;
          };
        };

        services = {
          guacamole = {
            enable = true;
            logo = true;
            fqdn = vars.domains.guacamoleFQDN;
            ldap = {
              enable = true;
              server = "mgc-drw-dmc01.${vars.domains.internalDomain}";
              user-base-dn = "ou=people,dc=prod,dc=megacorp,dc=industries";
              search-bind-dn = "uid=admin,ou=people,dc=prod,dc=megacorp,dc=industries";
              user-search-filter = "(memberof=cn=guacamole,ou=groups,dc=prod,dc=megacorp,dc=industries)";
              admin-ldap-password-file = "/run/secrets/lldap-admin-password";
              tls = {
                enable = true;
                root-cert = vars.keys.rootCert;
              };
            };
          };
        };

        virtualisation.libvirt.guest.enable = true;
      };
    }
  ];
}
