{
  nixpkgs,
  vars,
  self,
  ...
}:
nixpkgs.lib.nixosSystem {
  modules = [
    self.nixosModules.default
    {
      imports = [
        (import ../../base-config.nix {inherit vars;})
        (import ./backup.nix {inherit vars;})
        ./hardware-config.nix
      ];

      networking.hostName = "MGC-DRW-HVS01";

      system.stateVersion = "24.05";

      nixpkgs.config.allowUnfree = true;

      megacorp = {
        config = {
          bootloader = {
            enable = true;
            efi.enable = true;
          };

          networking = {
            static-ip = {
              enable = true;
              ipv4 = vars.networking.hostsAddr.MGC-DRW-HVS01.eth.ipv4;
              interface = vars.networking.hostsAddr.MGC-DRW-HVS01.eth.name;
              gateway = vars.networking.defaultGateway;
              nameservers = vars.networking.nameServers;
              lan-domain = vars.networking.internalDomain;
              bridge.enable = true;
            };
          };

          openssh = {
            enable = true;
            authorized-ssh-keys = vars.keys.bastionPubKey;
          };

          desktop = {
            enable = true;
            xrdp = true;
          };

          packages.ninja-cli.enable = true;
        };

        services = {
          controller.server.enable = true;

          comin = {
            enable = true;
            repo = "https://github.com/rapture-mc/mgc-machines";
          };
        };

        virtualisation.libvirt = {
          enable = true;
          logo = true;
          libvirt-users = [
            "${vars.adminUser}"
          ];
        };
      };
    }
  ];
}
