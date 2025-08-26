{
  nixpkgs,
  self,
  vars,
  sops-nix,
  ...
}:
nixpkgs.lib.nixosSystem {
  modules = [
    self.nixosModules.default
    sops-nix.nixosModules.sops
    ({modulesPath, ...}: {
      imports = [
        "${modulesPath}/virtualisation/amazon-image.nix"
        (import ../../_shared/common-config.nix {
          inherit vars;
        })
        # ./secrets.nix
      ];

      networking.hostName = "MGC-APSE2-BPS01";

      system.stateVersion = "25.05";

      nixpkgs.hostPlatform = nixpkgs.lib.mkDefault "x86_64-linux";
    })
  ];
}
