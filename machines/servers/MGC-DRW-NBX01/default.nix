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
            lan-domain = vars.domains.internalDomain;
          };
        };

        services = {
          netbox = {
            enable = true;
            fqdn = vars.domains.netboxFQDN;
            allowed-hosts = [
              "${vars.networking.hostsAddr.MGC-DRW-RVP01.eth.ipv4}"
              "${vars.networking.defaultGateway}"
              "https://${vars.domains.netboxFQDN}"
            ];
            tls.enable = false;
          };
        };

        virtualisation.libvirt.guest.enable = true;
      };
    }
  ];
}
