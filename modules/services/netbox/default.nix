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

  use-acme-cert =
    if cfg.tls.cert-key == null || cfg.tls.cert-file == null
    then true
    else false;
in {
  imports = [
    (mkIf cfg.tls.enable (import ../../_shared/nginx/tls-config.nix {
      inherit cfg lib use-acme-cert;
    }))
  ];

  options.megacorp.services.netbox = {
    enable = mkEnableOption "Enable Netbox";

    fqdn = mkOption {
      type = types.str;
      default = "localhost";
      description = ''
        The fqdn of your Netbox instance.
        NOTE: Don't include "https://" (this is prepended to the value)
      '';
    };

    port = mkOption {
      type = types.int;
      default = 8001;
      description = "The port number for file-browser to listen on";
    };

    allowed-hosts = mkOption  {
      type = types.listOf types.str;
      default = [];
      description = ''
        List of hosts allowed to connect to netbox

        If served behind a reverse proxy list the reverse proxy here
      '';
    };

    tls = import ../../_shared/nginx/tls-options.nix {
      inherit lib;
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      80
    ];

    services = {
      netbox = {
        enable = true;
        secretKeyFile = "/run/secrets/netbox-key-file";
        settings = {
          CSRF_TRUSTED_ORIGINS = [
            "https://${cfg.fqdn}"
          ];
          ALLOWED_HOSTS = [
            "[::1]"
            "${cfg.fqdn}"
          ] ++ cfg.allowed-hosts;
        };
      };

      nginx = {
        enable = true;
        user = "netbox";
        recommendedProxySettings = true;
        virtualHosts."${cfg.fqdn}" = {
          locations = {
            "/" = {
              proxyPass = lib.mkForce "http://[::1]:${toString cfg.port}";
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
