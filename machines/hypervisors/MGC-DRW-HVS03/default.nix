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
        (import ../../_shared/hypervisor-config.nix {
          inherit vars;
        })
      ];

      networking.hostName = "MGC-DRW-HVS03";

      system.stateVersion = "24.05";

      megacorp = {
        config = {
          bootloader.enable = true;

          networking = {
            static-ip = {
              enable = true;
              ipv4 = vars.networking.hostsAddr.MGC-DRW-HVS03.eth.ipv4;
              interface = vars.networking.hostsAddr.MGC-DRW-HVS03.eth.name;
              gateway = "192.168.10.1";
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

        virtualisation.libvirt.hypervisor.machines = {
          test-vm = {
            vm_hostname_prefix = "test-vm";
            memory = "6144";
            vcpu = 2;
          };
        };
      };
    }
  ];
}
