{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.megacorp.services.tailscale.server;

  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in {
  options.megacorp.services.tailscale.server = {
    enable = mkEnableOption "Whether to enable the open-source tailscale (headscale) server component";

    tls-email = mkOption {
      type = types.str;
      default = "someone@somedomain.com";
      description = ''
        The email to use for automatic SSL certificates.

        This email will also get SSL certificate renewal email notifications.

        Headscale requires TLS certificates for the server URL.
      '';
    };

    server-url = mkOption {
      type = types.str;
      default = "";
      description = ''
        The server URL which endpoints will connect to.

        Don't include https:// (will be prepended automatically to the server-url field).

        You must also setup the necessary A record so that your tailscale server is reachable via this domain.

        E.g. "tailscale.example.com"
      '';
    };

    base-domain = mkOption {
      type = types.str;
      default = "";
      description = ''
        The base domain that will be appended to each tailscale client.

        This must be different from server-url.

        E.g. "tailscale.example.net"
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      headscale
    ];

    security.acme.acceptTerms = true;
    security.acme.defaults.email = cfg.tls-email;

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    services = {
      nginx = {
        enable = true;
        virtualHosts."${cfg.server-url}" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://localhost:8080";
            proxyWebsockets = true;
          };
        };
      };

      headscale = {
        enable = true;
        address = "0.0.0.0";
        port = 8080;
        settings = {
          server_url = "https://${cfg.server-url}";
          dns.base_domain = cfg.base-domain;
        };
      };
    };
  };
}
