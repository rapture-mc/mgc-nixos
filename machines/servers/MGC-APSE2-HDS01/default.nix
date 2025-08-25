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
          gui = true;
          devices = {
            MGC-DRW-BST01.id = vars.syncthing.MGC-DRW-BST01.id;
          };
            folders = {
              sync = {
                path = "/home/ben.harris/Sync";
                devices = [
                  "MGC-DRW-BST01"
                ];
              };
            };
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
