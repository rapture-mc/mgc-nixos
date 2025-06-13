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
        (import ../../common-config.nix {
          inherit vars;
        })
        ./hardware-config.nix
      ];

      nixpkgs.config.allowUnfree = true;

      networking.hostName = "MGC-DRW-HVS02";

      system.stateVersion = "24.05";

      # The Ethernet card will suddenly stop working if too much data is transmitted over the link at one time. See https://www.reddit.com/r/Proxmox/comments/1drs89s/intel_nic_e1000e_hardware_unit_hang/?rdt=43359 for more info.
      systemd.services.fix-ethernet-bug = {
        enable = true;
        description = "This service provides a dirty hack to fix the Ethernet card on the Intel NUC (NUC10i5FNK).";
        serviceConfig.ExecStart = "${nixpkgs.legacyPackages.x86_64-linux.ethtool}/bin/ethtool -K ${vars.networking.hostsAddr.MGC-DRW-HVS02.eth.name} tso off gso off";
        unitConfig.After = "network-online.target";
        wantedBy = ["multi-user.target"];
      };

      # Extra packages
      environment.systemPackages = with pkgs; [
        gimp
        sioyek
      ];

      megacorp = {
        config = {
          bootloader = {
            enable = true;
            efi.enable = true;
          };

          networking = {
            static-ip = {
              enable = true;
              ipv4 = vars.networking.hostsAddr.MGC-DRW-HVS02.eth.ipv4;
              interface = vars.networking.hostsAddr.MGC-DRW-HVS02.eth.name;
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
        };

        services = {
          comin = {
            enable = true;
            repo = "https://github.com/rapture-mc/mgc-nixos";
          };
        };

        virtualisation.libvirt = {
          enable = true;
          logo = true;
          libvirt-users = [
            "${vars.adminUser}"
          ];
          declerative = {
            enable = true;
            machines = {
              bastion-server = {
                vm_hostname_prefix = "MGC-DRW-BST";
                memory = "6144";
                vcpu = 2;
              };

              domain-controller = {
                vm_hostname_prefix = "MGC-DRW-DMC";
                vcpu = 2;
              };

              reverse-proxy = {
                vm_hostname_prefix = "MGC-DRW-RVP";
                vcpu = 2;
                system_volume = 100;
              };

              desktop-gateway = {
                vm_hostname_prefix = "MGC-DRW-DGW";
                vcpu = 2;
              };

              file-browser = {
                vm_hostname_prefix = "MGC-DRW-FBR";
                vcpu = 2;
              };
            };
          };
        };
      };
    }
  ];
}
