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
  imports = [
    (mkIf cfg.tls.enable (import ../../_shared/nginx/tls-config.nix {
      inherit cfg lib use-acme-cert;
    }))
  ];

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

    tls = import ../../_shared/nginx/tls-options.nix {
      inherit lib;
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      80
    ];

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
