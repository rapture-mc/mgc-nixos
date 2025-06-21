{
  lib,
  config,
  ...
}: let
  cfg = config.megacorp.services.zabbix.agent;

  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in {
  options.megacorp.services.zabbix.agent = {
    enable = mkEnableOption "Whether to enable the Zabbix agent";

    server = mkOption {
      default = "127.0.0.1";
      type = types.str;
      description = "The address of the Zabbix server";
    };
  };

  config = mkIf cfg.enable {
    services.zabbixAgent = {
      enable = true;
      openFirewall = true;
      server = cfg.server;
    };
  };
}
