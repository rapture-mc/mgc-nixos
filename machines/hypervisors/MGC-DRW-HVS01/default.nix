{
  nixpkgs,
  vars,
  self,
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
        (import ./backup.nix {
          inherit vars;
        })
      ];

      networking.hostName = "MGC-DRW-HVS01";

      system.stateVersion = "24.05";

      systemd.watchdog.rebootTime = "15s";

      megacorp = {
        config = {
          bootloader = {
            enable = true;
            efi.enable = true;
          };
          networking = {
            static-ip = {
              enable = true;
              ipv4 = vars.networking.hostsAddr.MGC-DRW-HVS01.eth.ipv4;
              interface = vars.networking.hostsAddr.MGC-DRW-HVS01.eth.name;
              gateway = vars.networking.defaultGateway;
              nameservers = vars.networking.nameServers;
              lan-domain = vars.networking.internalDomain;
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
          ];
          terraform = {
            action = "plan";
            state-dir = "/var/lib/terranix-state/libvirt";
          };
          machines = {
            vault-servers = {
              vm_hostname_prefix = "MGC-DRW-VLT";
              vm_count = 1;
              memory = "8192";
              vcpu = 4;
            };

            test-box = {
              vm_hostname_prefix = "testbox";
              memory = "4096";
              running = false;
              autostart = false;
              vcpu = 2;
            };

            terminal-servers = {
              vm_hostname_prefix = "MGC-DRW-TMS";
              os_img_url = "/var/lib/libvirt/images/packer-win2022.qcow2";
              memory = "8192";
              vcpu = 3;
              autostart = false;
              running = false;
            };

            bookstack-servers = {
              vm_hostname_prefix = "MGC-DRW-BKS";
              memory = "4096";
              vcpu = 2;
              autostart = false;
              running = false;
            };

            semaphore-servers = {
              vm_hostname_prefix = "MGC-DRW-SEM";
              memory = "4096";
              vcpu = 2;
              autostart = false;
              running = false;
            };

            gitea-servers = {
              vm_hostname_prefix = "MGC-DRW-GIT";
              memory = "4096";
              vcpu = 2;
              autostart = false;
              running = false;
            };

            monitoring-servers = {
              vm_hostname_prefix = "MGC-DRW-MON";
              memory = "8192";
              vcpu = 4;
            };

            netbox-servers = {
              vm_hostname_prefix = "MGC-DRW-NBX";
              memory = "6144";
              vcpu = 2;
              autostart = false;
              running = false;
            };

            nextcloud-servers = {
              vm_hostname_prefix = "MGC-DRW-NXC";
              memory = "6144";
              vcpu = 2;
              autostart = false;
              running = false;
            };

            cloud-runners = {
              vm_hostname_prefix = "MGC-DRW-CLD";
              memory = "6144";
              vcpu = 2;
            };
          };
        };
      };
    }
  ];
}
