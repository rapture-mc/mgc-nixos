{
  lib,
  config,
  ...
}: let
  cfg = config.megacorp.services.bookstack;

  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in {
  options.megacorp.services.bookstack = {
    enable = mkEnableOption "Enable bookstack";

    logo = mkEnableOption "Whether to show bookstack logo on shell startup";

    reverse-proxied = mkEnableOption "Whether bookstack is served behind a reverse proxy";

    fqdn = mkOption {
      type = types.str;
      default = "localhost";
      description = "The fqdn of the bookstack instance.";
    };

    tls-email = mkOption {
      type = types.str;
      default = "someone@somedomain.com";
      description = ''
        The email to use for automatic SSL certificates
        This email will also get SSL certificate renewal email notifications
      '';
    };

    app-key-file = mkOption {
      type = types.str;
      default = "/run/secrets/bookstack-keyfile";
      description = "The path to the file containing the app key secret";
    };
  };

  config = mkIf cfg.enable {
    systemd.services."acme-${cfg.fqdn}".serviceConfig = { SuccessExitStatus = 10; };

    networking.firewall.allowedTCPPorts =
      [
        80
      ]
      ++ (
        if !cfg.reverse-proxied
        then [443]
        else []
      );

    security.acme = mkIf (!cfg.reverse-proxied) {
      acceptTerms = true;
      defaults.email = cfg.tls-email;
    };

    services.bookstack = {
      enable = true;
      hostname = cfg.fqdn;
      appKeyFile = cfg.app-key-file;
      database.createLocally = true;
      nginx = mkIf (!cfg.reverse-proxied) {
        enableACME = true;
        forceSSL = true;
      };
    };
  };
}
