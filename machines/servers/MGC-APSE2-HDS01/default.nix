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

      networking.hostName = "MGC-APSE2-HDS01";

      system.stateVersion = "25.05";

      nixpkgs.hostPlatform = nixpkgs.lib.mkDefault "x86_64-linux";

      environment.systemPackages = with pkgs; [
        headscale
      ];

      security.acme.acceptTerms = true;
      security.acme.defaults.email = "acme@${vars.domains.primaryDomain}";

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];

      services = {
        nginx = {
          enable = true;
          virtualHosts."net.${vars.domains.primaryDomain}" = {
            forceSSL = true;
            enableACME = true;
            locations."/" = {
              proxyPass = "http://localhost:8080";
              proxyWebsockets = true;
            };
          };
        };

        headscale = {
          enable = true;
          address = "0.0.0.0";
          port = 8080;
          settings = {
            server_url = "https://net.${vars.domains.primaryDomain}";
            dns = {
              base_domain = "megacorp.net";
            };
            log.level = "debug";
          };
        };
      };
    })
  ];
}
