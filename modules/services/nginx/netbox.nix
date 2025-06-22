{
  lib,
  config,
  ...
}: let
  cfg = config.megacorp.services.nginx.netbox;

  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in {
  options.megacorp.services.nginx.netbox = {
    enable = mkEnableOption "Enable netbox reverse proxy";

    ipv4 = mkOption {
      type = types.str;
      default = "192.168.1.4";
      description = "The IP of the file-browser instance";
    };

    fqdn = mkOption {
      type = types.str;
      default = "example.com";
      description = ''
        The fqdn of your file-browser instance.
        NOTE: Don't include "https://" (this is prepended to the value)
      '';
    };
  };

  config = {
    services = mkIf cfg.enable {
      nginx.virtualHosts."${cfg.fqdn}" = {
        forceSSL = true;
        enableACME = true;
        serverName = "${cfg.fqdn}";
        locations = {
          "/" = {
            proxyPass = "http://${cfg.ipv4}:80";
          };
          "/static/" = {
            proxyPass = "http://${cfg.ipv4}:80/static/";
          };
        };
      };
    };
  };
}

