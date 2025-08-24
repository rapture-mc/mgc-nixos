{
  nixpkgs,
  self,
  vars,
  sops-nix,
  nixos-mailserver,
  ...
}:
nixpkgs.lib.nixosSystem {
  modules = [
    self.nixosModules.default
    sops-nix.nixosModules.sops
    nixos-mailserver.nixosModules.default
    ({modulesPath, ...}: {
      imports = [
        "${modulesPath}/virtualisation/amazon-image.nix"
        ./secrets.nix
        (import ../../_shared/common-config.nix {
          inherit vars;
        })
      ];

      networking.hostName = "MGC-APSE2-MBX01";

      system.stateVersion = "25.05";

      nixpkgs.hostPlatform = nixpkgs.lib.mkDefault "x86_64-linux";

      mailserver = {
        enable = true;
        stateVersion = 3;
        fqdn = "mail.${vars.domains.primaryDomain}";
        domains = [
          "${vars.domains.primaryDomain}"
        ];

        loginAccounts = {
          "ben.harris@${vars.domains.primaryDomain}" = {
            hashedPasswordFile = "/run/secrets/mailserver-password-file";
            aliases = [
              "postmaster@${vars.domains.primaryDomain}"
            ];
          };
        };

        certificateScheme = "acme-nginx";
      };

      security.acme.acceptTerms = true;
      security.acme.defaults.email = "acme@${vars.domains.primaryDomain}";
    })
  ];
}
