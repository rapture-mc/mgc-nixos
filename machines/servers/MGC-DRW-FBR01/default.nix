{
  nixpkgs,
  megacorp,
  vars,
  ...
}:
nixpkgs.lib.nixosSystem {
  modules = [
    megacorp.nixosModules.default
    {
      imports = [
        ../../qemu-hardware-config.nix
        (import ../../base-config.nix {inherit vars;})
      ];

      networking.hostName = "MGC-DRW-FBR01";

      system.stateVersion = "24.11";

      megacorp = {
        config = {
          bootloader.enable = true;

          networking.static-ip = {
            enable = true;
            ipv4 = vars.networking.hostsAddr.MGC-DRW-FBR01.eth.ipv4;
            interface = vars.networking.hostsAddr.MGC-DRW-FBR01.eth.name;
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
            repo = "https://github.com/rapture-mc/mgc-machines";
          };

          file-browser = {
            enable = true;
            reverse-proxied = true;
            fqdn = "file-browser.megacorp.industries";
          };
        };

        virtualisation.qemu-guest.enable = true;
      };
    }
  ];
}
