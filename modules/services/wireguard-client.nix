{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.megacorp.services.wireguard-client;

  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in {
  options.megacorp.services.wireguard-client = {
    enable = mkEnableOption "Whether to wireguard client";

    private-key-file = mkOption {
      type = types.str;
      default = "/var/wireguard/private";
      description = "The path to the wireguard private key file";
    };

    ipv4 = mkOption {
      type = types.str;
      default = "10.100.0.2";
      description = "The wireguard IPv4 address of the client";
    };

    subnet = mkOption {
      type = types.str;
      default = "10.100.0.0";
      description = "The subnet for the wireguard hosts";
    };

    prefix = mkOption {
      type = types.int;
      default = 24;
      description = "The prefix for the wireguard hosts";
    };

    allowed-ips = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        IPs in CIDR notation that are allowed to send traffic to this wireguard client.

        The wireguard network CIDR is automatically added as an allowed IP.

        Note: If you want this client to access the wireguard servers private subnet add that subnet CIDR to this option
      '';
    };

    server = {
      ipv4 = mkOption {
        type = types.str;
        default = "";
        description = "The public IP address of the wireguard server";
      };

      port = mkOption {
        type = types.int;
        default = 51820;
        description = "The port of the wireguard server";
      };

      public-key = mkOption {
        type = types.str;
        default = "";
        description = "The public key of the wireguard server";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.wireguard-tools];

    networking = {
      firewall.allowedUDPPorts = [51820];
      wireguard = {
        enable = true;
        interfaces.wg0 = {
          ips = ["${cfg.ipv4}/${builtins.toString cfg.prefix}"];
          listenPort = 51820;
          privateKeyFile = cfg.private-key-file;
          peers = [
            {
              publicKey = "${cfg.server.public-key}";
              allowedIPs =
                [
                  "${cfg.subnet}/${builtins.toString cfg.prefix}"
                ]
                ++ cfg.allowed-ips;
              endpoint = "${cfg.server.ipv4}:${builtins.toString cfg.server.port}";
              persistentKeepalive = 25;
            }
          ];
        };
      };
    };
  };
}
