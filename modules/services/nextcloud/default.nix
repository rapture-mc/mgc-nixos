{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.megacorp.services.nextcloud;
  occCommand = "${config.services.nextcloud.occ}/bin/nextcloud-occ";

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

  options.megacorp.services.nextcloud = {
    enable = mkEnableOption "Enable Nextcloud";

    logo = mkEnableOption "Whether to show Nextcloud logo on shell startup";

    package = mkOption {
      type = types.package;
      default = pkgs.nextcloud31;
      description = "The nextcloud package instance";
    };

    port = mkOption {
      type = types.int;
      default = 80;
      description = "The port for nextcloud. This shouldn't ever change and is primarily used by the TLS nginx shared module'";
    };

    fqdn = mkOption {
      type = types.str;
      default = "localhost";
      description = ''
        The fqdn of your nextcloud instance.
        NOTE: Don't include "https://" (this is prepended to the value)
      '';
    };

    trusted-proxies = mkOption {
      type = types.listOf types.str;
      default = [""];
      description = "A list of trusted proxies";
    };

    backups = {
      enable = mkEnableOption "Whether to enable Nextcloud backup dumps";

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
    networking.firewall.allowedTCPPorts = [
      80
    ];

    environment.etc."nextcloud-default-admin-password".text = "changeme";

    services = {
      nextcloud = {
        enable = true;
        hostName = cfg.fqdn;
        package = cfg.package;
        database.createLocally = true;
        configureRedis = true;
        https =
          if cfg.tls.enable
          then true 
          else false;
        config = {
          dbtype = "pgsql";
          adminpassFile = "/etc/nextcloud-default-admin-password";
        };
        settings = {
          trusted_proxies = cfg.trusted-proxies;
          trusted_domains = ["${cfg.fqdn}"];
        };
      };
    };

    users = mkIf cfg.backups.enable {
      groups.nextcloud-backup = {};
      users = {
        nextcloud.extraGroups = ["nextcloud-backup"];
        nextcloud-backup = {
          home = "/var/lib/nextcloud-backup";
          createHome = true;
          homeMode = "770";
          group = "nextcloud-backup";
          isSystemUser = true;
        };
      };
    };

    systemd = mkIf cfg.backups.enable {
      timers."nextcloud-backup" = {
        wantedBy = ["timers.target"];
        requires = ["network-online.target"];
        timerConfig = {
          OnCalendar = cfg.backups.frequency;
          Persistent = true;
          Unit = "nextcloud-backup.service";
        };
      };

      services."nextcloud-backup" = {
        script = ''
          set -Eeuo pipefail
          if [ "$(id -un)" != "nextcloud" ] ;then
            echo "This script has to be run as the nextcloud user, aborting."
            exit 1
          fi

          echo "Enabling maintenance mode..."
          ${occCommand} maintenance:mod --on

          echo "Make backup directory $(date +%Y-%m-%d)"
          mkdir ${config.users.users.nextcloud-backup.home}/$(date +%Y-%m-%d)

          echo "Copy directory contents to backup diretory"
          ${pkgs.rsync}/bin/rsync -Aavx ${config.services.nextcloud.datadir} ${config.users.users.nextcloud-backup.home}/$(date +%Y-%m-%d)

          echo "Dump nextcloud database contents"
          ${pkgs.postgresql}/bin/pg_dump nextcloud -f ${config.users.users.nextcloud-backup.home}/$(date +%Y-%m-%d)/db.bak

          echo "Disabling maintenance mode..."
          ${occCommand} maintenance:mode --off
          echo "Nextcloud backup completed."
        '';
        serviceConfig = {
          Type = "oneshot";
          User = "nextcloud";
        };
      };
    };
  };
}
