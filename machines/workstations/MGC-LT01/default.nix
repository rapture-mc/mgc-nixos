{
  nixpkgs,
  self,
  vars,
  pkgs,
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

      networking.hostName = "MGC-LT01";

      system.stateVersion = "24.05";

      environment.systemPackages = with pkgs; [
        awscli2
        discord
        flameshot
        hello
        hledger
        hugo
        qbittorrent
        spotify
        sioyek
      ];

      virtualisation.docker.enable = true;

      services.nginx = {
        enable = true;
        virtualHosts."localhost" = {
          root = "/var/www/doco";
        };
      };

      services.xserver.enable = true;

      megacorp = {
        config = {
          bootloader = {
            enable = true;
            efi.enable = true;
          };

          desktop.enable = true;
        };

        programs.pass.enable = true;

        virtualisation.whonix.enable = true;

        system.ad-domain = {
          enable = true;
          domain-name = vars.domains.internalDomain;
          netbios-name = "PROD";
          # local-auth = {
          #   login = false;
          #   sudo = false;
          # };
        };
      };
    }
  ];
}
