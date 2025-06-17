{
  nixpkgs,
  self,
  vars,
  terranix,
  pkgs,
  system,
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
        # (import ./terranix.nix {
        #   inherit terranix pkgs system vars;
        # })
        # (import ./secrets.nix {
        #   inherit vars;
        # })
      ];

      networking.hostName = "MGC-DRW-VLT01";

      system.stateVersion = "24.11";

      # services.nginx = {
      #   enable = true;
      #   recommendedTlsSettings = true;
      #   recommendedProxySettings = true;
      #   virtualHosts."vault.megacorp.industries" = {
      #     forceSSL = true;
      #     sslCertificate = "/var/lib/nginx/vault-megacorp-industries.pem";
      #     sslCertificateKey = "/var/lib/nginx/private-key.pem";
      #     locations."/" = {
      #       proxyPass = "http://127.0.0.1:8200";
      #     };
      #   };
      # };

      megacorp = {
        config = {
          bootloader.enable = true;

          desktop = {
            xrdp = true;
            enable = true;
          };

          networking.static-ip = {
            enable = true;
            ipv4 = vars.networking.hostsAddr.MGC-DRW-VLT01.eth.ipv4;
            interface = vars.networking.hostsAddr.MGC-DRW-VLT01.eth.name;
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
          vault = {
            enable = true;
            gui = true;
            logo = true;
            open-firewall = true;
          };
        };

        virtualisation.libvirt.guest.enable = true;
      };
    }
  ];
}
