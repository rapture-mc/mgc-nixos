{
  lib,
  config,
  ...
}: let
  cfg = config.megacorp.services.nginx.semaphore;

  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in {
  options.megacorp.services.nginx.semaphore = {
    enable = mkEnableOption "Enable Semaphore reverse proxy";

    ipv4 = mkOption {
      type = types.str;
      default = "192.168.1.9";
      description = "The IP of the semaphore instance";
    };

    fqdn = mkOption {
      type = types.str;
      default = "example.com";
      description = ''
        The fqdn of your semaphore instance.
        NOTE: Don't include "https://" (this is prepended to the value)
      '';
    };
  };

  config = {
    services = mkIf cfg.enable {
      nginx.virtualHosts."${cfg.fqdn}" = {
        forceSSL = true;
        enableACME = true;
        locations = {
          "/" = {
            proxyPass = "http://${cfg.ipv4}:${toString config.megacorp.services.semaphore.port}";
          };
          "/api/ws" = {
            proxyPass = "http://${cfg.ipv4}:${toString config.megacorp.services.semaphore.port}/api/ws";
            proxyWebsockets = true;
          };
        };
      };
    };
  };
}
