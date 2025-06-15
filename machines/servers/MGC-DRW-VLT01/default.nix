{
  nixpkgs,
  self,
  vars,
  terranix,
  pkgs,
  system,
  sops-nix,
  ...
}:
nixpkgs.lib.nixosSystem {
  modules = [
    self.nixosModules.default
    sops-nix.nixosModules.sops
    {
      imports = [
        ../../_shared/qemu-hardware-config.nix
        (import ../../_shared/common-config.nix {
          inherit vars;
        })
        (import ./terranix.nix {
          inherit terranix pkgs system vars;
        })
        (import ./secrets.nix {
          inherit vars;
        })
      ];

      networking.hostName = "MGC-DRW-VLT01";

      system.stateVersion = "24.11";

      services.vault = {
        tlsKeyFile = "/var/lib/vault/private-key.pem";
        tlsCertFile = "/var/lib/vault/vault-megacorp-industries.pem";
      };

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];

      services.nginx = {
        enable = true;
        recommendedProxySettings = true;
        virtualHosts."vault.megacorp.industries" = {
          locations."/" = {
            proxyPass = "http://localhost:8200";
          };
        };
      };

      megacorp = {
        config = {
          bootloader.enable = true;

          networking.static-ip = {
            enable = true;
            ipv4 = vars.networking.hostsAddr.MGC-DRW-VLT01.eth.ipv4;
            interface = vars.networking.hostsAddr.MGC-DRW-VLT01.eth.name;
            gateway = vars.networking.defaultGateway;
            nameservers = vars.networking.nameServers;
            lan-domain = vars.networking.internalDomain;
          };

          openssh = {
            enable = true;
            authorized-ssh-keys = vars.keys.bastionPubKey;
          };
        };

        services = {
          comin = {
            enable = true;
            repo = "https://github.com/rapture-mc/mgc-nixos";
          };

          vault = {
            enable = true;
            gui = true;
            logo = true;
            open-firewall = true;
            address = vars.networking.hostsAddr.MGC-DRW-VLT01.eth.ipv4;
          };
        };

        virtualisation.libvirt.guest.enable = true;
      };
    }
  ];
}
