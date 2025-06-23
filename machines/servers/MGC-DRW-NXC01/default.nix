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
        # (import ./secrets.nix {
        #   inherit vars;
        # })
      ];

      networking.hostName = "MGC-DRW-NXC01";

      system.stateVersion = "25.05";

      megacorp = {
        config = {
          bootloader.enable = true;

          networking.static-ip = {
            enable = true;
            ipv4 = vars.networking.hostsAddr.MGC-DRW-NXC01.eth.ipv4;
            interface = vars.networking.hostsAddr.MGC-DRW-NXC01.eth.name;
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
          nextcloud = {
            enable = true;
            logo = true;
            fqdn = vars.nextcloudFQDN;
            tls.enable = false;
          };
        };

        virtualisation.libvirt.guest.enable = true;
      };
    }
  ];
}
