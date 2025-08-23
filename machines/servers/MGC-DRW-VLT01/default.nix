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

      networking.hostName = "MGC-DRW-VLT01";

      system.stateVersion = "24.11";

      megacorp = {
        config = {
          bootloader.enable = true;

          networking.static-ip = {
            enable = true;
            ipv4 = vars.networking.hostsAddr.MGC-DRW-VLT01.eth.ipv4;
            interface = vars.networking.hostsAddr.MGC-DRW-VLT01.eth.name;
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

        services = {
          vault = {
            enable = true;
            gui = true;
            logo = true;
            open-firewall = true;
            address = "vault.${vars.domains.internalDomain}";

            tls = {
              enable = true;
              cert-file = "/var/lib/nginx/vault.crt";
              cert-key = "/var/lib/nginx/vault.pem";
            };

            pki = {
              enable = true;
              terraform = {
                state-dir = "/var/lib/terranix-state/vault";
              };

              certs = {
                bookstack = {
                  common_name = "bookstack.${vars.domains.internalDomain}";
                };

                grafana = {
                  common_name = "grafana.${vars.domains.internalDomain}";
                };

                mgc-drw-frw01 = {
                  common_name = "mgc-drw-frw01.${vars.domains.internalDomain}";
                };

                mgc-drw-dmc01 = {
                  common_name = "mgc-drw-dmc01.${vars.domains.internalDomain}";
                };

                semaphore = {
                  common_name = "semaphore.${vars.domains.internalDomain}";
                };

                snipe-it = {
                  common_name = "snipe-it.${vars.domains.internalDomain}";
                };

                vault = {
                  common_name = "vault.${vars.domains.internalDomain}";
                };

                zabbix = {
                  common_name = "zabbix.${vars.domains.internalDomain}";
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
