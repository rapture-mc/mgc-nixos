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

  options.megacorp.services.gitea = {
    enable = mkEnableOption "Enable Gitea";

    logo = mkEnableOption "Whether to show Gitea logo on shell startup";

    disable-registration = mkEnableOption ''
      Disable the account registration option on the main homepage
    '';

    fqdn = mkOption {
      type = types.str;
      default = "localhost";
      description = ''
        The fqdn of your gitea instance.
        NOTE: Don't include "https://" (this is prepended to the value)
      '';
    };

    port = mkOption {
      type = types.int;
      default = 3001;
      description = "The port number for file-browser to listen on";
    };

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

    tls = import ../../_shared/nginx/tls-options.nix {
      inherit lib;
    };
  };

  config = mkIf cfg.enable {
    users.groups.gitea.members = ["${config.megacorp.config.users.admin-user}"];

    networking.firewall.allowedTCPPorts = [
      80
    ];

    services = {
      nginx = {
        enable = true;
        recommendedProxySettings = true;
        virtualHosts."${cfg.fqdn}" = {
          locations = {
            "/" = {
              proxyPass = "http://127.0.0.1:${toString cfg.port}";
            };
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
            ROOT_URL = "http://${cfg.fqdn}/";
            HTTP_PORT = cfg.port;
          };
          service = {
            DISABLE_REGISTRATION = cfg.disable-registration;
          };
        };
      };
    };
  };
}
