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
            lan-domain = vars.networking.internalDomain;
          };

          openssh = {
            enable = true;
            authorized-ssh-keys = vars.keys.bastionPubKey;
          };
        };

        services = {
          grafana = {
            enable = true;
            logo = true;
            fqdn = vars.grafanaFQDN;
            tls = {
              enable = true;
              cert-file = "/var/lib/nginx/grafana.megacorp.industries.crt";
              cert-key = "/var/lib/nginx/grafana.megacorp.industries.pem";
            };
          };

          zabbix = {
            server = {
              enable = true;
              fqdn = vars.zabbixFQDN;
              tls = {
                enable = false;
                cert-file = "/var/lib/nginx/zabbix.megacorp.industries.crt";
                cert-key = "/var/lib/nginx/zabbix.megacorp.industries.pem";
              };
            };
          };
        };

        virtualisation.libvirt.guest.enable = true;
      };
    }
  ];
}
