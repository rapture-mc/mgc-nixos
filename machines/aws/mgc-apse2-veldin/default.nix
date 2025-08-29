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

      networking.hostName = "mgc-apse2-veldin";

      system.stateVersion = "25.05";

      nixpkgs.hostPlatform = nixpkgs.lib.mkDefault "x86_64-linux";

      services = {
        fail2ban.enable = true;

        enable = true;
        openFirewall = true;
        signal.relayHosts = [
          "127.0.0.1"
        ];
      };

      megacorp = {
        config.openssh = {
          bastion-logo = true;
          allow-password-auth = true;
        };

        programs.pass.enable = true;

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
