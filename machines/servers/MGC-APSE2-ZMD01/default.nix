{
  nixpkgs,
  pkgs,
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

      networking.hostName = "MGC-APSE2-ZMD01";

      system.stateVersion = "25.05";

      nixpkgs.hostPlatform = nixpkgs.lib.mkDefault "x86_64-linux";

      services.tailscale.enable = true;

      networking.firewall = {
        checkReversePath = "loose";
        trustedInterfaces = [
          "tailscale0"
        ];
        allowedUDPPorts = [
          41641
        ];
      };
    })
  ];
}
