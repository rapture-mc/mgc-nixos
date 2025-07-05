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
      ];

      networking.hostName = "MGC-LT02";

      system.stateVersion = "24.05";

      megacorp = {
        config = {
          bootloader = {
            enable = true;
            efi.enable = true;
          };

          desktop.enable = true;
        };

        virtualisation.whonix.enable = true;
      };
    }
  ];
}
