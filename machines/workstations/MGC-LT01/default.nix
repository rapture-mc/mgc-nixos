{
  nixpkgs,
  self,
  system,
  terranix,
  vars,
  ...
}: let
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
in
  nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.default
      {
        imports = [
          (import ../../common-config.nix {
            inherit vars;
          })
          (import ./infra.nix {inherit pkgs terranix system;})
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

          services = {
            # wireguard-client = {
            #   enable = true;
            #   ipv4 = vars.networking.hostsAddr.MGC-LT01.wireguard.ipv4;
            #   allowed-ips = ["${vars.networking.privateLANSubnet}"];
            #   server = {
            #     ipv4 = vars.networking.wireguardPublicIP;
            #     public-key = vars.keys.wireguardPubKeys.MGC-DRW-CTR01;
            #   };
            # };

            comin = {
              enable = true;
              repo = "https://github.com/rapture-mc/mgc-nixos";
            };

            password-store.enable = true;
          };

          virtualisation.whonix.enable = true;
        };
      }
    ];
  }
