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

      system.stateVersion = "25.05";

      megacorp = {
        services.tailscale.client.enable = true;
        config = {
          bootloader = {
            enable = true;
            efi.enable = true;
          };

          desktop.enable = true;
        };
      };
    }
  ];
}
