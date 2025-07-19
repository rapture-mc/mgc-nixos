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

          networking.static-ip = {
            enable = true;
            ipv4 = vars.networking.hostsAddr.MGC-DRW-BST01.eth.ipv4;
            interface = vars.networking.hostsAddr.MGC-DRW-BST01.eth.name;
            gateway = vars.networking.defaultGateway;
            nameservers = ["192.168.1.7"];
            lan-domain = vars.domains.internalDomain;
          };

          openssh = {
            allowed-groups = [
              "rg-authorized_bastion_users"
            ];

            bastion = {
              enable = true;
              logo = true;
            };
          };

          system.ad-domain = {
            enable = true;
            domain-name = vars.domains.internalDomain;
            netbios-name = "PROD";
          };
        };

        programs.pass.enable = true;

        virtualisation.libvirt.guest.enable = true;
      };
    }
  ];
}
