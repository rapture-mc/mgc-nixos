{
  nixpkgs,
  megacorp,
  sops-nix,
  vars,
  ...
}: let
  domain-component = "dc=megacorp,dc=industries";
in
  nixpkgs.lib.nixosSystem {
    modules = [
      megacorp.nixosModules.default
      sops-nix.nixosModules.sops
      {
        imports = [
          ../../qemu-hardware-config.nix
          (import ../../base-config.nix {inherit vars;})
          (import ./secrets.nix {inherit vars;})
        ];

        networking.hostName = "MGC-DRW-DMC01";

        system.stateVersion = "24.11";

        megacorp = {
          config = {
            bootloader.enable = true;

            networking.static-ip = {
              enable = true;
              ipv4 = vars.networking.hostsAddr.MGC-DRW-DMC01.eth.ipv4;
              interface = vars.networking.hostsAddr.MGC-DRW-DMC01.eth.name;
              gateway = vars.networking.defaultGateway;
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

            dnsmasq = {
              enable = true;
              domain = vars.networking.internalDomain;
              hosts = ''
                ${vars.networking.hostsAddr.MGC-DRW-DGW01.eth.ipv4} MGC-DRW-DGW01
                ${vars.networking.hostsAddr.MGC-DRW-BST01.eth.ipv4} MGC-DRW-BST01
                ${vars.networking.hostsAddr.MGC-DRW-RST01.eth.ipv4} MGC-DRW-RST01
                ${vars.networking.hostsAddr.MGC-DRW-RVP01.eth.ipv4} MGC-DRW-RVP01
                ${vars.networking.hostsAddr.MGC-DRW-HVS01.eth.ipv4} MGC-DRW-HVS01
                ${vars.networking.hostsAddr.MGC-DRW-HVS02.eth.ipv4} MGC-DRW-HVS02
                ${vars.networking.hostsAddr.MGC-DRW-HVS03.eth.ipv4} MGC-DRW-HVS03
                ${vars.networking.hostsAddr.MGC-DRW-DMC01.eth.ipv4} MGC-DRW-DMC01
                ${vars.networking.hostsAddr.MGC-DRW-FBR01.eth.ipv4} MGC-DRW-FBR01
                192.168.1.99 MGC-DRW-FRW01
              '';
            };

            openldap = {
              enable = true;
              domain-component = domain-component;
              logo = true;
              extra-declarative-contents = ''
                dn: cn=John Smith,ou=IT,ou=Users,${domain-component}
                objectClass: person
                cn: John Smith
                sn: Smith

                dn: cn=Tony Poo,ou=IT,ou=Users,${domain-component}
                objectClass: person
                cn: Tony Poo
                sn: Poo
              '';
            };
          };

          virtualisation.qemu-guest.enable = true;
        };
      }
    ];
  }
