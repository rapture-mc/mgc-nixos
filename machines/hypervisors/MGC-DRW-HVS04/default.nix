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
        ./hardware-config.nix
        (import ../../_shared/common-config.nix {
          inherit vars;
        })
        (import ../../_shared/server-config.nix {
          inherit vars;
        })
      ];

      networking.hostName = "MGC-DRW-HVS04";

      system.stateVersion = "25.05";

      virtualisation.docker.enable = true;

      networking.firewall.allowedTCPPorts = [ 3000 ];

      megacorp = {
        config = {
          bootloader = {
            enable = true;
            efi.enable = true;
          };

          networking = {
            static-ip = {
              enable = true;
              ipv4 = vars.networking.hostsAddr.MGC-DRW-HVS04.eth.ipv4;
              interface = vars.networking.hostsAddr.MGC-DRW-HVS04.eth.name;
              gateway = vars.networking.defaultGateway;
              nameservers = vars.networking.nameServers;
              lan-domain = vars.domains.internalDomain;
              bridge.enable = true;
            };
          };

          desktop = {
            enable = true;
            xrdp = true;
          };
        };

        virtualisation.libvirt.hypervisor = {
          enable = true;
          logo = true;
          libvirt-users = [
            "${vars.adminUser}"
            "ben.harris"
          ];
          terraform.state-dir = "/var/lib/terranix-state/libvirt";
          machines = {
            monitoring-servers = {
              vm_hostname_prefix = "MGC-DRW-MON";
              memory = "8192";
              vcpu = 4;
            };

            domain-controllers = {
              vm_hostname_prefix = "MGC-DRW-DMC";
              os_img_url = "/var/lib/libvirt/images/win22-core.qcow2";
              memory = "8192";
              vcpu = 4;
            };

            jump-box = {
              vm_hostname_prefix = "MGC-DRW-JMP";
              os_img_url = "/var/lib/libvirt/images/win22-gui.qcow2";
              memory = "8192";
              vcpu = 4;
            };
          };
        };
      };
    }
  ];
}
