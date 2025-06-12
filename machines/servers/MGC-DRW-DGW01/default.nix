{
  nixpkgs,
  pkgs,
  vars,
  self,
  ...
}:
nixpkgs.lib.nixosSystem {
  modules = [
    self.nixosModules.default
    {
      imports = [
        ../../qemu-hardware-config.nix
        (import ../../common-config.nix {
          inherit vars;
        })
      ];

      networking.hostName = "MGC-DRW-DGW01";

      system.stateVersion = "24.11";

      # Applying overlays
      services.guacamole-server.package = pkgs.guacamole-server;
      environment.systemPackages = [
        pkgs.freerdp
      ];

      megacorp = {
        config = {
          bootloader.enable = true;

          networking.static-ip = {
            enable = true;
            ipv4 = vars.networking.hostsAddr.MGC-DRW-DGW01.eth.ipv4;
            interface = vars.networking.hostsAddr.MGC-DRW-DGW01.eth.name;
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

          guacamole = {
            enable = true;
            logo = true;
            reverse-proxied = true;
          };
        };

        virtualisation.libvirt.guest.enable = true;
      };
    }
  ];
}
