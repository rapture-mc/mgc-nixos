{
  lib,
  config,
  pkgs,
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

  use-acme-cert = if cfg.tls.cert-key == null || cfg.tls.cert-file == null then true else false;

in {
  options.megacorp.services.bookstack = {
    enable = mkEnableOption "Enable bookstack";

    logo = mkEnableOption "Whether to show bookstack logo on shell startup";

    fqdn = mkOption {
      type = types.str;
      default = "localhost";
      description = "The fqdn of the bookstack instance.";
    };

    app-key-file = mkOption {
      type = types.str;
      default = "/run/secrets/bookstack-keyfile";
      description = "The path to the file containing the app key secret";
    };

    tls = {
      enable = mkEnableOption ''
        Whether to enable TLS.

        If this option is set to true and tls.cert-private-key or tls.cert-file are null, a signed certifiacate will be requested using ACME. If the proper networking/DNS are not setup a self-signed certificate will be used instead.
      '';

      cert-key = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Path to the TLS certificate private key file";
      };

      cert-file = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Path to the TLS certificate file";
      };

      email = mkOption {
        type = types.str;
        default = "someone@somedomain.com";
        description = ''
          The email to use for automatic SSL certificates
          This email will also get SSL certificate renewal email notifications
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services."acme-${cfg.fqdn}".serviceConfig = mkIf use-acme-cert {SuccessExitStatus = 10;};

    networking.firewall.allowedTCPPorts =
      [
        80
      ]
      ++ (
        if cfg.tls.enable
        then [443]
        else []
      );

    security.acme = mkIf use-acme-cert {
      acceptTerms = true;
      defaults.email = cfg.tls.email;
    };

    services.bookstack = {
      enable = true;
      hostname = cfg.fqdn;
      package = pkgs.bookstack;
      appKeyFile = cfg.app-key-file;
      database.createLocally = true;
      nginx = mkIf cfg.tls.enable {
        enableACME = if use-acme-cert then true else false;
        forceSSL = true;
        sslCertificate = if !use-acme-cert then cfg.tls.cert-file else null;
        sslCertificateKey = if !use-acme-cert then cfg.tls.cert-key else null;
      };
    };
  };
}
