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

      virtualisation = {
        waydroid.enable = true;
        docker.enable = true;
      };

      services.nginx = {
        enable = true;
        virtualHosts."localhost" = {
          root = "/var/www/doco";
        };
      };

      services.xserver.enable = true;

      megacorp = {
        services = {
          tailscale.client.enable = true;

          syncthing = {
            enable = true;
            user = "ben.harris";
            gui = {
              enable = true;
              # password-file = "/run/secrets/syncthing-admin-password";
            };
            devices = {
              MGC-APSE2-HDS01.id = vars.syncthing.MGC-APSE2-HDS01.id;
              MGC-DRW-BST01.id = vars.syncthing.MGC-DRW-BST01.id;
            };
            folders = {
              sync = {
                path = "/home/ben.harris/Sync";
                devices = [
                  "MGC-APSE2-HDS01"
                  "MGC-DRW-BST01"
                ];
              };
            };
          };
        };

        config = {
          bootloader = {
            enable = true;
            efi.enable = true;
          };

          users.benny = {
            sudo = true;
            authorized-ssh-keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzlYmoWjZYFeCNdMBCHBXmqpzK1IBmRiB3hNlsgEtre benny@MGC-DRW-BST01"
            ];
          };

          desktop.enable = true;

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

        programs.pass.enable = true;

        virtualisation.whonix.enable = true;
      };
    }
  ];
}
