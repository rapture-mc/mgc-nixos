{
  nixpkgs,
  pkgs,
  megacorp,
  vars,
  terranix,
  system,
  ...
}:
nixpkgs.lib.nixosSystem {
  modules = [
    megacorp.nixosModules.default
    {
      imports = [
        (import ../../base-config.nix {inherit vars;})
        (import ./infra.nix {inherit pkgs vars terranix system;})
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

      # Extra stuff
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
              nameservers = ["8.8.8.8" "8.8.4.4"];
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
            repo = "https://github.com/rapture-mc/mgc-machines";
          };
        };

        virtualisation.hypervisor = {
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
