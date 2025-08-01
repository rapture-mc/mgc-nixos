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

      system.stateVersion = "25.05";

      networking.hostName = "test-vm01";

      megacorp = {
        virtualisation.libvirt.guest.enable = true;

        config = {
          bootloader.enable = true;

          networking.static-ip = {
            enable = true;
            ipv4 = "192.168.10.50";
            interface = "ens3";
            gateway = "192.168.10.1";
            nameservers = [
              "192.168.1.7"
            ];
            lan-domain = "prod.megacorp.industries";
          };
        };
      };
    }
  ];
}
