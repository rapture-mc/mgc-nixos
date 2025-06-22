{
  lib,
  config,
  ...
}: let
  cfg = config.megacorp.services.dnsmasq;

  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in {
  options.megacorp.services.dnsmasq = {
    enable = mkEnableOption "Enable dnsmasq";

    domain = mkOption {
      type = types.str;
      default = "localhost";
      description = "The domain name that dnsmasq will be deployed in";
    };

    nameservers = mkOption {
      type = types.listOf types.str;
      default = [
        "8.8.8.8"
        "8.8.4.4"
      ];
      description = "The nameservers dnsmasq should use for all other DNS queries";
    };

    hosts = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Custom hosts that DNSMASQ should resolve in /etc/hosts format.

        This option creates a new file /etc/custom-hosts and doesn't use the default /etc/hosts file because the hostname of the dnsmasq server (when queried) will otherwise resolve to 127.0.0.2 when queried. As in "ping dnsmasq-server" resolves to the localhost of the machine making the query instead of the IP address of the dnsmasq server.

        Example value:
        local-server 192.168.1.50
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.etc.custom-hosts = {
      enable = true;
      text =
        ''
          127.0.0.1 localhost
          ::1 localhost
        ''
        + cfg.hosts;
    };

    services = {
      dnsmasq = {
        enable = true;
        settings = {
          cache-size = 1000;
          server = cfg.nameservers;
          domain-needed = true;
          expand-hosts = true;
          domain = cfg.domain;
          bogus-priv = true;
          no-hosts = true;
          addn-hosts = "/etc/custom-hosts";
        };
      };

      resolved.extraConfig = ''
        DNSStubListener=no
      '';
    };

    networking.firewall.allowedUDPPorts = [53];
  };
}
