{
  nixpkgs,
  pkgs,
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
        (import ./website.nix {
          inherit pkgs;
        })
      ];

      networking.hostName = "MGC-DRW-RVP01";

      system.stateVersion = "24.11";

      megacorp = {
        config = {
          bootloader.enable = true;

          networking.static-ip = {
            enable = true;
            ipv4 = vars.networking.hostsAddr.MGC-DRW-RVP01.eth.ipv4;
            interface = vars.networking.hostsAddr.MGC-DRW-RVP01.eth.name;
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
          comin = {
            enable = true;
            repo = "https://github.com/rapture-mc/mgc-nixos";
          };

          nginx = {
            enable = true;
            logo = true;
            guacamole = {
              enable = true;
              ipv4 = vars.networking.hostsAddr.MGC-DRW-DGW01.eth.ipv4;
              fqdn = vars.guacamoleFQDN;
            };

            file-browser = {
              enable = true;
              ipv4 = vars.networking.hostsAddr.MGC-DRW-FBR01.eth.ipv4;
              fqdn = vars.file-browserFQDN;
            };

            semaphore = {
              enable = true;
              ipv4 = vars.networking.hostsAddr.MGC-DRW-SEM01.eth.ipv4;
              fqdn = vars.semaphoreFQDN;
            };

            gitea = {
              enable = true;
              ipv4 = vars.networking.hostsAddr.MGC-DRW-GIT01.eth.ipv4;
              fqdn = vars.giteaFQDN;
            };

            grafana = {
              enable = true;
              ipv4 = vars.networking.hostsAddr.MGC-DRW-MON01.eth.ipv4;
              fqdn = vars.grafanaFQDN;
            };

            zabbix = {
              enable = true;
              ipv4 = vars.networking.hostsAddr.MGC-DRW-MON01.eth.ipv4;
              fqdn = vars.zabbixFQDN;
            };

            netbox = {
              enable = true;
              ipv4 = vars.networking.hostsAddr.MGC-DRW-NBX01.eth.ipv4;
              fqdn = vars.netboxFQDN;
            };

            nextcloud = {
              enable = true;
              ipv4 = vars.networking.hostsAddr.MGC-DRW-NXC01.eth.ipv4;
              fqdn = vars.nextcloudFQDN;
            };
          };
        };

        virtualisation.libvirt.guest.enable = true;
      };
    }
  ];
}
