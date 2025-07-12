{
  nixpkgs,
  self,
  vars,
  ...
}:
nixpkgs.lib.nixosSystem {
  modules = [
    self.nixosModules.default
    {
      imports = [
        ../../_shared/qemu-hardware-config.nix
        (import ../../_shared/common-config.nix {
          inherit vars;
        })
      ];

      networking.hostName = "MGC-DRW-MON01";

      system.stateVersion = "25.05";

      megacorp = {
        config = {
          bootloader.enable = true;

          networking.static-ip = {
            enable = true;
            ipv4 = vars.networking.hostsAddr.MGC-DRW-MON01.eth.ipv4;
            interface = vars.networking.hostsAddr.MGC-DRW-MON01.eth.name;
            gateway = vars.networking.defaultGateway;
            nameservers = vars.networking.nameServers;
            lan-domain = vars.domains.internalDomain;
          };
        };

        services = {
          grafana = {
            enable = true;
            logo = true;
            fqdn = vars.domains.grafanaFQDN;
            tls = {
              enable = true;
              cert-file = "/var/lib/nginx/grafana.crt";
              cert-key = "/var/lib/nginx/grafana.pem";
            };
          };

          zabbix = {
            agent.enable = true;
            server = {
              enable = true;
              fqdn = vars.domains.zabbixFQDN;
              tls = {
                enable = true;
                cert-file = "/var/lib/nginx/zabbix.crt";
                cert-key = "/var/lib/nginx/zabbix.pem";
              };
            };
          };
        };

        virtualisation.libvirt.guest.enable = true;
      };
    }
  ];
}
