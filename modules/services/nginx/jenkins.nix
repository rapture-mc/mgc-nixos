{
  lib,
  config,
  ...
}: let
  cfg = config.megacorp.services.nginx.jenkins;

  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in {
  options.megacorp.services.nginx.jenkins = {
    enable = mkEnableOption "Enable Gitea reverse proxy";

    ipv4 = mkOption {
      type = types.str;
      default = "192.168.1.10";
      description = "The IP of the jenkins instance";
    };

    fqdn = mkOption {
      type = types.str;
      default = "example.com";
      description = ''
        The fqdn of your jenkins instance.
        NOTE: Don't include "https://" (this is prepended to the value)
      '';
    };
  };

  config = {
    services = mkIf cfg.enable {
      nginx.virtualHosts."${cfg.fqdn}" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://${cfg.ipv4}:8080";
        };
      };
    };
  };
}
