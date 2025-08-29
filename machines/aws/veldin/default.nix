{
  nixpkgs,
  self,
  vars,
  ...
}:
nixpkgs.lib.nixosSystem {
  modules = [
    self.nixosModules.default
    ({modulesPath, ...}: {
      imports = [
        "${modulesPath}/virtualisation/amazon-image.nix"
        (import ../../_shared/common-config.nix {
          inherit vars;
        })
      ];

      networking.hostName = "veldin";

      system.stateVersion = "25.05";

      nixpkgs.hostPlatform = nixpkgs.lib.mkDefault "x86_64-linux";

      megacorp.config.openssh = {
        bastion-logo = true;
        allow-password-auth = true;
      };
    })
  ];
}
