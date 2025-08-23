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
        (import ../../_shared/common-config.nix {
          inherit vars;
        })
      ];

      networking.hostName = "MGC-DRW-MBX01";

      system.stateVersion = "25.05";
    }
  ];
}
