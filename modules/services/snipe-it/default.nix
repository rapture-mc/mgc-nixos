{
  lib,
  config,
  ...
}: let
  cfg = config.megacorp.services.snipe-it;

  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;

  use-acme-cert =
    if cfg.tls.cert-key == null || cfg.tls.cert-file == null
    then true
    else false;
in {
  options.megacorp.services.snipe-it = {
    enable = mkEnableOption "Enable Snipe-IT";

    fqdn = mkOption {
      type = types.str;
      default = "localhost";
      description = ''
        The fqdn of your Snipe-IT instance.
        NOTE: Don't include "https://" (this is prepended to the value)
      '';
    };

    app-key-file = mkOption {
      type = types.path;
      default = "/run/secrets/snipe-keyfile";
      description = "The snipe-it keyfile";
    };

    tls = import ../../_shared/nginx/tls-options.nix {
      inherit lib;
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      80
    ];

    services.snipe-it = {
      enable = true;
      hostName = cfg.fqdn;
      appKeyFile = cfg.app-key-file;
      database.createLocally = true;
      nginx = mkIf cfg.tls.enable {
        enableACME =
          if use-acme-cert
          then true
          else false;
        forceSSL = true;
        sslCertificate =
          if !use-acme-cert
          then cfg.tls.cert-file
          else null;
        sslCertificateKey =
          if !use-acme-cert
          then cfg.tls.cert-key
          else null;
      };
    };
  };
}
