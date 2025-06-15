{
  nixpkgs,
  self,
  vars,
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
        (import ./backup.nix {
          inherit vars;
        })
        (import ./secrets.nix {
          inherit vars;
        })
      ];

      networking.hostName = "MGC-DRW-BST01";

      system.stateVersion = "24.11";

      megacorp = {
        config = {
          bootloader.enable = true;

          desktop.enable = true;

          networking.static-ip = {
            enable = true;
            ipv4 = vars.networking.hostsAddr.MGC-DRW-BST01.eth.ipv4;
            interface = vars.networking.hostsAddr.MGC-DRW-BST01.eth.name;
            gateway = vars.networking.defaultGateway;
            nameservers = vars.networking.nameServers;
            lan-domain = vars.networking.internalDomain;
          };

          openssh = {
            enable = true;
            authorized-ssh-keys = vars.keys.authorizedBastionPubKeys;
            bastion = {
              enable = true;
              logo = true;
            };
          };
        };

        programs.pass.enable = true;

        services = {
          comin = {
            enable = true;
            repo = "https://github.com/rapture-mc/mgc-nixos";
          };
        };

        virtualisation.libvirt.guest.enable = true;
      };
    }
  ];
}
