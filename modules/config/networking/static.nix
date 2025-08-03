{
  lib,
  config,
  ...
}: let
  cfg = config.megacorp.config.networking.static-ip;

  inherit
    (lib)
    mkOption
    mkForce
    mkEnableOption
    types
    mkIf
    ;
in {
  options.megacorp.config.networking.static-ip = {
    enable = mkEnableOption ''
      Enable a static IP on an interface.

      Note: This method uses systemd-networkd (the recommened way) to set a static IP on an interface.
      This also disables NetworkManager in the process to prevent 2 services from simultaneously managing the same interface.
    '';

    interface = mkOption {
      type = types.str;
      default = "ens3";
      description = "The primary network interface of the host machine";
    };

    ipv4 = mkOption {
      type = types.str;
      default = "192.168.1.2";
      description = "The IPv4 address of the host machine";
    };

    prefix = mkOption {
      type = types.int;
      default = 24;
      description = "The subnet CIDR for the host machine";
    };

    gateway = mkOption {
      type = types.str;
      default = "192.168.1.1";
      description = "The IP of the host machines gateway";
    };

    nameservers = mkOption {
      type = types.listOf types.str;
      default = ["192.168.1.1"];
      description = "List of IP addresses of the nameservers for the host";
    };

    lan-domain = mkOption {
      type = types.str;
      default = "localhost";
      description = "The host machines domain it belongs to";
    };

    bridge = {
      enable = mkEnableOption "Make physical interface a bridge interface";

      name = mkOption {
        type = types.str;
        default = "br0";
        description = "The name of the bridge interface";
      };
    };
  };

  config = mkIf cfg.enable {
    networking = {
      networkmanager.enable = mkForce false;
      domain = cfg.lan-domain;
      useDHCP = false;
      useNetworkd = true;
    };

    systemd.services."systemd-networkd".environment.SYSTEMD_LOG_LEVEL = "debug";

    services.resolved = {
      llmnr = "false";
    };

    systemd.network = {
      enable = true;

      netdevs.${cfg.bridge.name} = {
        enable = cfg.bridge.enable;
        netdevConfig = {
          Kind = "bridge";
          Name = cfg.bridge.name;
        };
      };

      networks = {
        # Configure IP settings on bridge interface
        "${cfg.bridge.name}-lan" = {
          enable = cfg.bridge.enable;
          matchConfig.Name = [
            cfg.bridge.name
          ];

          networkConfig = {
            Bridge = cfg.bridge.name;
          };
        };

        "${cfg.bridge.name}-lan-bridge" = {
          enable = cfg.bridge.enable;
          matchConfig = {
            Name = cfg.bridge.name;
          };

          networkConfig = {
            DHCP = "no";
            Address = "${cfg.ipv4}/${builtins.toString cfg.prefix}";
            DNS = cfg.nameservers;
            Domains = cfg.lan-domain;
          };

          routes = [
            {
              Destination = "0.0.0.0/0";
              Gateway = cfg.gateway;
            }
          ];
        };

        ${cfg.interface} = {
          matchConfig = {
            Name = cfg.interface;
          };

          networkConfig = {
            Bridge = mkIf cfg.bridge.enable cfg.bridge.name;
            DHCP = "no";
            Address = mkIf (!cfg.bridge.enable) "${cfg.ipv4}/${builtins.toString cfg.prefix}";
            DNS = cfg.nameservers;
            Domains = cfg.lan-domain;
          };

          routes = mkIf (!cfg.bridge.enable) [
            {
              Destination = "0.0.0.0/0";
              Gateway = cfg.gateway;
            }
          ];
        };
      };
    };
  };
}
