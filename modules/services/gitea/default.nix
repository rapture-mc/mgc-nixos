{
  lib,
  config,
  ...
}: let
  cfg = config.megacorp.services.gitea;

  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in {
  options.megacorp.services.gitea = {
    enable = mkEnableOption "Enable Gitea";

    logo = mkEnableOption "Whether to show Gitea logo on shell startup";

    reverse-proxied = mkEnableOption "Whether Gitea is served behind a reverse proxy";

    backups = {
      enable = mkEnableOption "Whether to enable Gitea backup dumps";

      frequency = mkOption {
        type = types.str;
        default = "Fri *-*-* 23:55:00";
        description = ''
          How often the backups should run in systemd.timer format
          Default is every Friday at 11:55PM
        '';
      };
    };

    disable-registration = mkEnableOption ''
      Disable the account registration option on the main homepage
    '';

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
        The fqdn of your gitea instance.
        NOTE: Don't include "https://" (this is prepended to the value)
      '';
    };
  };

  config = mkIf cfg.enable {
    users.groups.gitea.members = ["${config.megacorp.config.users.admin-user}"];

    networking.firewall.allowedTCPPorts =
      [
        3001
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

    services = {
      # Reads as if not reversed proxied, enable nginx (default), otherwise dont enable nginx
      nginx = mkIf (!cfg.reverse-proxied) {
        enable = true;
        virtualHosts."${cfg.fqdn}" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://localhost:3001/";
          };
        };
      };

      gitea = {
        enable = true;
        appName = "Gitea Server";
        dump = mkIf cfg.backups.enable {
          enable = true;
          interval = cfg.backups.frequency;
        };
        database = {
          type = "postgres";
        };

        settings = {
          server = {
            DOMAIN = "${cfg.fqdn}";
            ROOT_URL = "https://${cfg.fqdn}/";
            HTTP_PORT = 3001;
          };
          service = {
            DISABLE_REGISTRATION = cfg.disable-registration;
          };
        };
      };
    };
  };
}
