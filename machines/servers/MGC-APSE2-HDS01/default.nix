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

      networking.hostName = "MGC-APSE2-HDS01";

      system.stateVersion = "25.05";

      nixpkgs.hostPlatform = nixpkgs.lib.mkDefault "x86_64-linux";

      megacorp.services = {
        syncthing = {
          enable = true;
          user = "ben.harris";
        };

        tailscale = {
          client.enable = true;
          server = {
            enable = true;
            server-url = "net.${vars.domains.primaryDomain}";
            base-domain = "megacorp.net";
          };
        };
      };
    })
  ];
}
