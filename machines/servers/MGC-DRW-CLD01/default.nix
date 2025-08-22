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
            lan-domain = vars.domains.internalDomain;
          };
        };

        cloud.aws.ec2 = {
          enable = true;
          credential-path = "/home/benny/.aws/credentials";
          config-path = "/home/benny/.aws/config";
          terraform.state-dir = "/var/lib/terranix-state/aws/ec2";
          machines = {
            mail-server = {
              instance_type = "t2.medium";
              associate_public_ip_address = true;
              root_block_device.size = 30;
            };
          };
        };

        virtualisation.libvirt.guest.enable = true;
      };
    }
  ];
}
