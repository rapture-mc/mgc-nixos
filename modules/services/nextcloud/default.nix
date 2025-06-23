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
in {
  options.megacorp.services.nextcloud = {
    enable = mkEnableOption "Enable Nextcloud";

    package = mkOption {
      type = types.package;
      default = pkgs.nextcloud29;
      description = "The nextcloud package instance";
    };

    logo = mkEnableOption "Whether to show Nextcloud logo on shell startup";

    reverse-proxied = mkEnableOption "Whether Nextcloud is served behind a reverse proxy";

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

    tls-email = mkOption {
      type = types.str;
      default = "someone@somedomain.com";
      description = ''
        The email to use for automatic SSL certificates
        This email will also get SSL certificate renewal email notifications
      '';
    };

    fqdn = mkOption {
      type = types.str;
      default = "localhost";
      description = ''
        The fqdn of your nextcloud instance.
        NOTE: Don't include "https://" (this is prepended to the value)
      '';
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = (
      if !cfg.reverse-proxied
      then [80 443]
      else []
    );

    security.acme = mkIf (!cfg.reverse-proxied) {
      acceptTerms = true;
      defaults.email = "${cfg.tls-email}";
    };

    environment.etc."nextcloud-admin-password".text = "changeme";

    services = {
      # Reads as if not reversed proxied, enable nginx (default), otherwise dont enable nginx
      nginx = mkIf (!cfg.reverse-proxied) {
        enable = true;
        virtualHosts."${cfg.fqdn}" = {
          forceSSL = true;
          enableACME = true;
        };
      };

      nextcloud = {
        enable = true;
        hostName = "${cfg.fqdn}";
        package = cfg.package;
        database.createLocally = true;
        configureRedis = true;
        https =
          if cfg.reverse-proxied
          then false
          else true;
        config = {
          dbtype = "pgsql";
          adminpassFile = "/etc/nextcloud-admin-password";
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
