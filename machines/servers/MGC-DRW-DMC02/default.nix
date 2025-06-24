{
  nixpkgs,
  vars,
  self,
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
          (import ./bind.nix {
            inherit pkgs vars;
          })
        ];

        networking.hostName = "MGC-DRW-DMC02";

        system.stateVersion = "25.05";

        networking.firewall.allowedUDPPorts = [
          53
        ];

        services.bind = {
          enable = true;
          forwarders = [
            "8.8.8.8"
            "8.8.4.4"
          ];
          zones."prod.megacorp.industries" = let
            internal-domain = "prod.megacorp.industries";
            email-contact = "ict.megacorp.industries";
            name-server = "mgc-drw-dmc02";
          in {
            master = true;
            file = pkgs.writeText "zone-${internal-domain}" ''
              $ORIGIN ${internal-domain}.
              $TTL    1h
              @                 IN              SOA         ${name-server}.${internal-domain}. ${email-contact} (
                                                            2025062401  ; 2025-06-24 Revision 01
                                                            7200        ; Slave servers should check for updates every 2 hours
                                                            3600        ; Slave servers should wait 1 hour before trying a failed refresh
                                                            1209600     ; Slave servers will serve requests for 2 weeks if it can't refresh
                                                            3600        ; TTL
                                                            )

              @                 IN              NS          ${name-server}.${internal-domain}.
              ${name-server}    IN              A           ${vars.networking.hostsAddr.MGC-DRW-DMC02.eth.ipv4}

              
              netbox            IN              A           ${vars.networking.hostsAddr.MGC-DRW-NBX01.eth.ipv4}
            '';
          };
        };

        megacorp = {
          config = {
            bootloader.enable = true;

            networking.static-ip = {
              enable = true;
              ipv4 = vars.networking.hostsAddr.MGC-DRW-DMC02.eth.ipv4;
              interface = vars.networking.hostsAddr.MGC-DRW-DMC02.eth.name;
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
          };

          virtualisation.libvirt.guest.enable = true;
        };
      }
    ];
  }
