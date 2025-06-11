{
  nixpkgs,
  pkgs,
  megacorp,
  vars,
  ...
}:
nixpkgs.lib.nixosSystem {
  modules = [
    megacorp.nixosModules.default
    {
      imports = [
        ./hardware-config.nix
        (import ../../common-config.nix {inherit vars;})
      ];

      nixpkgs.config.allowUnfree = true;

      networking.hostName = "MGC-DRW-HVS03";

      system.stateVersion = "24.05";

      environment.systemPackages = with pkgs; [
        devenv
        direnv
        hugo
      ];

      services.xserver.enable = true;

      megacorp = {
        config = {
          bootloader.enable = true;

          networking = {
            static-ip = {
              enable = true;
              ipv4 = vars.networking.hostsAddr.MGC-DRW-HVS03.eth.ipv4;
              interface = vars.networking.hostsAddr.MGC-DRW-HVS03.eth.name;
              gateway = vars.networking.defaultGateway;
              nameservers = vars.networking.nameServers;
              lan-domain = vars.networking.internalDomain;
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
        };

        services = {
          comin = {
            enable = true;
            repo = "https://github.com/rapture-mc/mgc-machines";
          };
        };

        virtualisation.whonix.enable = true;
      };
    }
  ];
}
