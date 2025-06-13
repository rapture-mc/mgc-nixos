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
        (import ../../common-config.nix {
          inherit vars;
        })
        ./hardware-config.nix
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

          openssh = {
            enable = true;
            authorized-ssh-keys = vars.keys.bastionPubKey;
          };

          desktop.enable = true;
        };

        programs.pass.enable = true;

        services = {
          comin = {
            enable = true;
            repo = "https://github.com/rapture-mc/mgc-nixos";
          };
        };

        virtualisation.whonix.enable = true;
      };
    }
  ];
}
