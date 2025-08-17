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
              port = 636;
              server = "mgc-drw-dmc01.${vars.domains.internalDomain}";
              user-base-dn = "OU=Users,OU=MGC,DC=prod,DC=megacorp,DC=industries";
              search-bind-dn = "CN-LDAP Service Account,OU=Service Accounts,OU=Users,OU=MGC,DC=prod,DC=megacorp,DC=industries";
              user-search-filter = "(memberof=CN=RG - Guacamole Users,OU=Roll Groups,OU=Groups,OU=MGC,DC=prod,DC=megacorp,DC=industries)";
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
