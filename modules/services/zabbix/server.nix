# This module doesn't use the the shared nginx module
# If it does use the shared nginx module it causes a 502 bad gateway error
{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.megacorp.services.zabbix.server;

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
  options.megacorp.services.zabbix.server = {
    enable = mkEnableOption "Whether to enable Zabbix server (also enables web server)";

    fqdn = mkOption {
      type = types.str;
      default = "localhost";
      description = ''
        The fqdn of your Zabbix instance.
        NOTE: Don't include "https://" (this is prepended to the value)
      '';
    };

    port = mkOption {
      type = types.int;
      default = 10051;
      description = "The port number for file-browser to listen on";
    };

    tls = import ../../_shared/nginx/tls-options.nix {
      inherit lib;
    };
  };

  config = mkIf cfg.enable {
    security.acme = mkIf use-acme-cert {
      acceptTerms = true;
      defaults.email = cfg.tls.email;
    };

    systemd.services."acme-${cfg.fqdn}".serviceConfig = mkIf use-acme-cert {SuccessExitStatus = 10;};

    networking.firewall.allowedTCPPorts = [
      80
    ];

    # See https://github.com/NixOS/nixpkgs/issues/417572
    services.phpfpm.pools.zabbix.phpPackage = pkgs.php83;

    services = {
      zabbixServer = {
        enable = true;
        openFirewall = true;
      };

      zabbixWeb = {
        enable = true;
        hostname = cfg.fqdn;
        frontend = "nginx";
        nginx.virtualHost = mkIf cfg.tls.enable {
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
  };
}
