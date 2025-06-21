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

    tls = import ../../_shared/nginx-tls.nix {
      inherit lib;
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
