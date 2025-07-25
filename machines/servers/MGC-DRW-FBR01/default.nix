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
        ../../_shared/qemu-hardware-config.nix
        (import ../../_shared/common-config.nix {
          inherit vars;
        })
        (import ../../_shared/server-config.nix {
          inherit vars;
        })
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
            lan-domain = vars.domains.internalDomain;
          };
        };

        services = {
          file-browser = {
            enable = true;
            fqdn = vars.domains.file-browserFQDN;
            tls = {
              enable = false;
              cert-file = "/var/lib/nginx/mgc-drw-fbr01.crt";
              cert-key = "/var/lib/nginx/mgc-drw-fbr01.pem";
            };
          };
        };

        virtualisation.libvirt.guest.enable = true;
      };
    }
  ];
}
