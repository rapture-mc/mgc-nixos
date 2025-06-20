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
              cert-file = "/var/lib/nginx/mgc-drw-vlt01.crt";
              cert-key = "/var/lib/nginx/mgc-drw-vlt01.pem";
            };

            pki = {
              enable = true;
              certs = {
                mgc-drw-vlt01 = {
                  common_name = "mgc-drw-vlt01.${vars.networking.internalDomain}";
                };
                bookstack = {
                  common_name = "bookstack.${vars.networking.internalDomain}";
                };
                mgc-drw-fbr01 = {
                  common_name = "mgc-drw-fbr01.${vars.networking.internalDomain}";
                };
                mgc-drw-sem01 = {
                  common_name = "mgc-drw-sem01.${vars.networking.internalDomain}";
                };
                mgc-drw-git01 = {
                  common_name = "mgc-drw-git01.${vars.networking.internalDomain}";
                };
                grafana = {
                  common_name = "grafana.${vars.networking.internalDomain}";
                };
                zabbix = {
                  common_name = "zabbix.${vars.networking.internalDomain}";
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
