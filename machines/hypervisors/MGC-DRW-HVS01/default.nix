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

          openssh = {
            enable = true;
            authorized-ssh-keys = vars.keys.bastionPubKey;
          };

          desktop = {
            enable = true;
            xrdp = true;
          };
        };

        services = {
          comin = {
            enable = true;
            repo = "https://github.com/rapture-mc/mgc-nixos";
          };
        };

        virtualisation.libvirt = {
          enable = true;
          logo = true;
          libvirt-users = [
            "${vars.adminUser}"
          ];
          declerative = {
            enable = true;
            machines = {
              vault-servers = {
                vm_hostname_prefix = "MGC-DRW-VLT";
                vm_count = 2;
                memory = "8192";
                vcpu = 4;
              };
              terminal-servers = {
                vm_hostname_prefix = "MGC-DRW-TMS";
                os_img_url = "/var/lib/libvirt/images/packer-win2022.qcow2";
                memory = "8192";
                vcpu = 3;
                autostart = false;
                running = false;
              };
            };
          };
        };
      };
    }
  ];
}
