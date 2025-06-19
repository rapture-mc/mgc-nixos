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

      networking.hostName = "MGC-DRW-VLT01";

      system.stateVersion = "24.11";

      megacorp = {
        config = {
          bootloader.enable = true;

          desktop = {
            xrdp = true;
            enable = true;
          };

          networking.static-ip = {
            enable = true;
            ipv4 = vars.networking.hostsAddr.MGC-DRW-VLT01.eth.ipv4;
            interface = vars.networking.hostsAddr.MGC-DRW-VLT01.eth.name;
            gateway = vars.networking.defaultGateway;
            nameservers = vars.networking.nameServers;
            lan-domain = vars.networking.internalDomain;
          };

          openssh = {
            enable = true;
            authorized-ssh-keys = vars.keys.bastionPubKey;
          };
        };

        services = {
          vault = {
            enable = true;
            gui = true;
            logo = true;
            open-firewall = true;
            address = "mgc-drw-vlt01.megacorp.industries";
            tls = {
              enable = true;
              cert-file = "/var/lib/vault/generated-certs/mgc-drw-vlt01.crt";
              cert-private-key = "/var/lib/vault/generated-certs/mgc-drw-vlt01.pem";
            };
            pki = {
              enable = true;
              certs = {
                mgc-drw-vlt01 = {
                  common_name = "mgc-drw-vlt01.${vars.networking.internalDomain}";
                };

                mgc-drw-vlt02 = {
                  common_name = "mgc-drw-vlt02.${vars.networking.internalDomain}";
                };
                mgc-drw-frw01 = {
                  common_name = "mgc-drw-drw01.${vars.networking.internalDomain}";
                };
                mgc-drw-dmc01 = {
                  common_name = "mgc-drw-dmc01.${vars.networking.internalDomain}";
                };
                mgc-drw-bst01 = {
                  common_name = "mgc-drw-bst01.${vars.networking.internalDomain}";
                };
              };
            };
          };
        };

        virtualisation.libvirt.guest.enable = true;
      };
    }
  ];
}
