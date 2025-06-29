{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.megacorp.services.lldap;

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
  imports = [
    (mkIf cfg.tls.enable (import ../../_shared/nginx/tls-config.nix {
      inherit cfg lib use-acme-cert;
    }))
    (mkIf cfg.enable (import ../../_shared/packages/godap.nix {
      inherit lib pkgs;
    }))
  ];

  options.megacorp.services.lldap = {
    enable = mkEnableOption "Enable Grafana";

    base-dn = mkOption {
      type = types.str;
      default = "dc=example,dc=com";
      description = "Base DN of the LDAP instance.";
    };

    fqdn = mkOption {
      type = types.str;
      default = "localhost";
      description = ''
        The fqdn of your LLDAP instance.
        NOTE: Don't include "https://" (this is prepended to the value)
      '';
    };

    port = mkOption {
      type = types.int;
      default = 17170;
      description = "The port number for lldap to listen on";
    };

    tls = import ../../_shared/nginx/tls-options.nix {
      inherit lib;
    };

    ldap-tls = {
      enable = mkEnableOption "Whether to enable LDAP TLS";

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
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      80
      3890
    ] ++ (
      if cfg.ldap-tls.enable
      then [ 6360 ]
      else []
    );

    services = {
      nginx = {
        enable = true;
        virtualHosts."${cfg.fqdn}" = {
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.port}";
            recommendedProxySettings = true;
          };
        };
      };

      lldap = {
        enable = true;
        settings = {
          http_url = "http://${cfg.fqdn}";
          ldap_base_dn = "${cfg.base-dn}";
          ldaps_options = mkIf cfg.ldap-tls.enable {
            enabled = true;
            port = 6360;
            cert_file = cfg.ldap-tls.cert-file;
            key_file = cfg.ldap-tls.cert-key;
          };
        };
      };
    };
  };
}
