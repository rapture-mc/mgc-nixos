{
  lib,
  config,
  ...
}: let
  cfg = config.megacorp.services.jenkins;

  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in {
  options.megacorp.services.jenkins = {
    enable = mkEnableOption "Enable Jenkins";

    reverse-proxied = mkEnableOption "Whether Jenkins is served behind a reverse proxy";

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
        The fqdn of your Jenkins instance.
        NOTE: Don't include "https://" (this is prepended to the value)
      '';
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts =
      [
        8080
      ]
      ++ (
        if !cfg.reverse-proxied
        then [80 443]
        else []
      );

    security.acme = mkIf (!cfg.reverse-proxied) {
      acceptTerms = true;
      defaults.email = "${cfg.tls-email}";
    };

    # Reads as if not reversed proxied, enable nginx (default), otherwise dont enable nginx
    services = {
      nginx = mkIf (!cfg.reverse-proxied) {
        enable = true;
        virtualHosts."${cfg.fqdn}" = {
          forceSSL = true;
          enableACME = true;
          locations."/".proxyPass = "http://127.0.0.1:8080";
        };
      };

      jenkins = {
        enable = true;
      };
    };
  };
}
