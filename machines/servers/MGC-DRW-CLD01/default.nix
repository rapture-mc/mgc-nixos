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
        ../../_shared/qemu-hardware-config.nix
        (import ../../_shared/common-config.nix {
          inherit vars;
        })
        (import ./route53.nix {
          inherit vars;
        })
      ];

      networking.hostName = "MGC-DRW-CLD01";

      system.stateVersion = "25.05";

      environment.systemPackages = [
        pkgs.awscli2
      ];

      megacorp = {
        config = {
          bootloader.enable = true;

          networking.static-ip = {
            enable = true;
            ipv4 = vars.networking.hostsAddr.MGC-DRW-CLD01.eth.ipv4;
            interface = vars.networking.hostsAddr.MGC-DRW-CLD01.eth.name;
            gateway = vars.networking.defaultGateway;
            nameservers = vars.networking.nameServers;
            lan-domain = vars.networking.internalDomain;
          };
        };

        cloud.aws.ec2 = {
          enable = true;
          credential-path = "/home/${vars.adminUser}/.aws/credentials";
          config-path = "/home/${vars.adminUser}/.aws/config";
          instance = {
            enable = true;
            public-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKhKBbO3gu8cbKQYOopVAA9gkSHHChkjMYPgfW2NIBrN benny@MGC-LT01";
          };
        };

        virtualisation.libvirt.guest.enable = true;
      };
    }
  ];
}
