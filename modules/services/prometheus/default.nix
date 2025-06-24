{
  lib,
  config,
  ...
}: let
  cfg = config.megacorp.services.prometheus;

  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in {
  options.megacorp.services.prometheus = {
    enable = mkEnableOption "Enable Prometheus";

    node-exporter.enable = mkEnableOption "Enable Prometheus node exporter";

    scraper = {
      enable = mkEnableOption "Enable Prometheus scraping";

      targets = mkOption {
        type = types.listOf types.str;
        default = [""];
        description = "List of targets to scrape";
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts =
      [
        9001
      ]
      ++ (
        if cfg.node-exporter.enable
        then [9002]
        else []
      );

    services.prometheus = {
      enable = true;
      port = 9001;
      globalConfig.scrape_interval = "10s";
      scrapeConfigs = mkIf cfg.scraper.enable [
        {
          job_name = "scrape-all";
          static_configs = [
            {
              targets = ["127.0.0.1:9002"] ++ cfg.scraper.targets;
            }
          ];
        }
      ];
      exporters = mkIf cfg.node-exporter.enable {
        node = {
          enable = true;
          enabledCollectors = ["systemd"];
          port = 9002;
        };
      };
    };
  };
}
