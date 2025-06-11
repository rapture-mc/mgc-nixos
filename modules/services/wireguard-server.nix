{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.megacorp.services.wireguard-server;

  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in {
  options.megacorp.services.wireguard-server = {
    enable = mkEnableOption "Whether to wireguard server";

    logo = mkEnableOption "Whether to show wireguard logo on shell startup";

    physical-interface = mkOption {
      type = types.str;
      default = "ens3";
      description = ''
        The physical interface of the wireguard server.

        This should be the same interface that internet traffic leaves from for the wireguard server.
      '';
    };

    peers = mkOption {
      type = types.listOf types.attrs;
      default = [
        {
          publicKey = "";
          allowedIPs = ["10.100.0.2/32"];
        }
      ];
      description = ''
        A list of peers that can connect to the wireguard server.

        Each list entry should be an attribute set containing the public key of the wireguard peer as well as the peers wireguard IP with a /32 CIDR.
      '';
    };

    private-key-file = mkOption {
      type = types.str;
      default = "/var/wireguard/private";
      description = "The path to the wireguard private key file";
    };

    ipv4 = mkOption {
      type = types.str;
      default = "10.100.0.1";
      description = "The wireguard IPv4 address of the server";
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

    port = mkOption {
      type = types.int;
      default = 51820;
      description = "The wireguard server port";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.wireguard-tools];

    networking = {
      firewall.allowedUDPPorts = [cfg.port];
      nat = {
        enable = true;
        internalInterfaces = ["wg0"];
        externalInterface = cfg.physical-interface;
      };

      wireguard = {
        enable = true;
        interfaces.wg0 = {
          ips = ["${cfg.ipv4}/${builtins.toString cfg.prefix}"];
          listenPort = cfg.port;
          postSetup = ''
            ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${cfg.subnet}/${builtins.toString cfg.prefix} -o ${cfg.physical-interface} -j MASQUERADE
          '';
          postShutdown = ''
            ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${cfg.subnet}/${builtins.toString cfg.prefix} -o ${cfg.physical-interface} -j MASQUERADE
          '';
          privateKeyFile = cfg.private-key-file;
          generatePrivateKeyFile = true;
          peers = cfg.peers;
        };
      };
    };
  };
}
