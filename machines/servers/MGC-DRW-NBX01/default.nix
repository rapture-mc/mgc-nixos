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
        (import ./secrets.nix {
          inherit vars;
        })
      ];

      networking.hostName = "MGC-DRW-NBX01";

      system.stateVersion = "25.05";

      megacorp = {
        config = {
          bootloader.enable = true;

          networking.static-ip = {
            enable = true;
            ipv4 = vars.networking.hostsAddr.MGC-DRW-NBX01.eth.ipv4;
            interface = vars.networking.hostsAddr.MGC-DRW-NBX01.eth.name;
            gateway = vars.networking.defaultGateway;
            nameservers = vars.networking.nameServers;
            lan-domain = vars.networking.internalDomain;
          };
        };

        services = {
          netbox = {
            enable = true;
            fqdn = vars.netboxFQDN;
            allowed-hosts = [
              "${vars.networking.hostsAddr.MGC-DRW-RVP01.eth.ipv4}"
              "https://${vars.netboxFQDN}"
              "192.168.1.99"
            ];
            tls.enable = false;
          };
        };

        virtualisation.libvirt.guest.enable = true;
      };
    }
  ];
}
