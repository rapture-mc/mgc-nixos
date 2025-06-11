{
  lib,
  config,
  ...
}: let
  cfg = config.megacorp.services.nginx;

  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in {
  imports = [
    ./file-browser.nix
    ./gitea.nix
    ./guacamole.nix
    ./grafana.nix
    ./jenkins.nix
    ./nextcloud.nix
    ./semaphore.nix
    ./zabbix.nix
  ];

  options.megacorp.services.nginx = {
    enable = mkEnableOption "Enable Nginx reverse proxy";

    logo = mkEnableOption "Whether to show nginx logo on shell startup";

    tls-email = mkOption {
      type = types.str;
      default = "someone@somedomain.com";
      description = ''
        The email to use for automatic SSL certificates
        This email will also get SSL certificate renewal email notifications
      '';
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [80 443];

    security.acme = {
      acceptTerms = true;
      defaults.email = "${cfg.tls-email}";
    };

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
    };
  };
}
