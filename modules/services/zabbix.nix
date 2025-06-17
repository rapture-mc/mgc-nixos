{
  lib,
  config,
  ...
}: let
  cfg = config.megacorp.services.zabbix;

  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in {
  options.megacorp.services.zabbix = {
    server = {
      enable = mkEnableOption "Whether to enable Zabbix server (also enables web server)";
      reverse-proxied = mkEnableOption "Whether Zabbix is served behind a reverse proxy";

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
          The fqdn of your Zabbix instance.
          NOTE: Don't include "https://" (this is prepended to the value)
        '';
      };
    };

    agent = {
      enable = mkEnableOption "Whether to enable the Zabbix agent";
    };
  };

  config = mkIf (cfg.server.enable || cfg.agent.enable) {
    networking.firewall.allowedTCPPorts = (
      if cfg.server.enable
      then [
        80
      ] else []
      ) ++ (
        if !cfg.server.reverse-proxied
        then [443]
        else []
      );

    security.acme = mkIf (!cfg.server.reverse-proxied) {
      acceptTerms = true;
      defaults.email = "${cfg.server.tls-email}";
    };

    systemd.services."acme-${cfg.server.fqdn}".serviceConfig.SuccessExitStatus = 10; # Allow self-signed SSL certificates

    services = {
      zabbixServer = mkIf cfg.server.enable {
        enable = true;
        openFirewall = true;
      };

      zabbixWeb = {
        enable = cfg.server.enable;
        hostname = cfg.server.fqdn;
        frontend = "nginx";
        nginx.virtualHost = {
          forceSSL =
            if cfg.server.reverse-proxied
            then false
            else true;
          enableACME =
            if cfg.server.reverse-proxied
            then false
            else true;
        };
      };

      zabbixAgent = mkIf cfg.agent.enable {
        enable = true;
        openFirewall = true;
        server =
          if cfg.server.enable
          then "127.0.0.1"
          else cfg.server.fqdn;
      };
    };
  };
}
