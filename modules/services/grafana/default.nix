{
  lib,
  config,
  ...
}: let
  cfg = config.megacorp.services.grafana;

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

  options.megacorp.services.grafana = {
    enable = mkEnableOption "Enable Grafana";

    logo = mkEnableOption "Whether to show Grafana logo on shell startup";

    fqdn = mkOption {
      type = types.str;
      default = "localhost";
      description = ''
        The fqdn of your Grafana instance.
        NOTE: Don't include "https://" (this is prepended to the value)
      '';
    };

    port = mkOption {
      type = types.int;
      default = 2342;
      description = "The port number for grafana to listen on";
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
      nginx = {
        enable = true;
        virtualHosts."${cfg.fqdn}" = {
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.port}";
            recommendedProxySettings = true;
            proxyWebsockets = true;
          };
        };
      };

      grafana = {
        enable = true;
        provision = {
          enable = true;
          datasources.settings.datasources = [
            {
              name = "localhost - prometheus";
              type = "prometheus";
              url = "http://localhost:9001";
            }
          ];
        };

        settings.server = {
          domain = cfg.fqdn;
          http_port = cfg.port;
        };
      };
    };
  };
}
