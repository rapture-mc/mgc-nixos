# See below link for why Netbox can't be setup with an external reverse proxy
# https://github.com/netbox-community/netbox/discussions/15922
{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.megacorp.services.netbox;

  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in {
  options.megacorp.services.netbox = {
    enable = mkEnableOption "Enable Netbox";

    tls-email = mkOption {
      type = types.str;
      default = "someone@somedomain.com";
      description = ''
        The email to use for automatic SSL certificates
        This email will also get SSL certificate renewal email notifications
      '';
    };

    fqdn = mkOption {
      type = types.str;
      default = "localhost";
      description = ''
        The fqdn of your Netbox instance.
        NOTE: Don't include "https://" (this is prepended to the value)
      '';
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [80 443];

    security.acme = {
      acceptTerms = true;
      defaults.email = "${cfg.tls-email}";
    };

    systemd.services."netbox-generate-key-file" = {
      enable = false;
      requiredBy = [
        "netbox-housekeeping.service"
      ];
      serviceConfig = {
        User = "netbox";
      };
      script = ''
        ${pkgs.openssl}/bin/openssl rand -hex 50 > /var/lib/netbox/secret-key-file
      '';
    };

    services = {
      netbox = {
        enable = true;
        secretKeyFile = "/run/secrets//netbox-key-file";
        settings.ALLOWED_HOSTS = [
          "[::1]"
          "${cfg.fqdn}"
          "https://${cfg.fqdn}"
        ];
      };

      nginx = {
        enable = true;
        user = "netbox";
        clientMaxBodySize = "25m";
        recommendedTlsSettings = true;
        recommendedProxySettings = true;
        virtualHosts."${cfg.fqdn}" = {
          forceSSL = true;
          enableACME = true;
          serverName = "${cfg.fqdn}";
          locations = {
            "/" = {
              proxyPass = "http://[::1]:8001";
            };
            "/static/" = {
              alias = "${config.services.netbox.dataDir}/static/";
            };
          };
        };
      };
    };
  };
}
