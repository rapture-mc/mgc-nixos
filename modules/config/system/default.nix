{
  lib,
  config,
  ...
}: let
  cfg = config.megacorp.config.system;

  inherit
    (lib)
    mkOption
    mkEnableOption
    mkIf
    types
    ;
in {
  imports = [
    ./ad-domain.nix
  ];

  options.megacorp.config.system = {
    enable = mkEnableOption ''
      Whether to allow Megacorp to control essential system related settings.

      Things such as nix-daemon settings, timezone, system-locale and other stuff.
    '';

    timezone = mkOption {
      type = types.str;
      default = "Australia/Darwin";
      description = "Timezone to set.";
    };

    locale = mkOption {
      type = types.str;
      default = "en_AU.UTF-8";
      description = "The default system locale.";
    };
  };

  config = mkIf cfg.enable {
    time.timeZone = cfg.timezone;

    i18n.defaultLocale = "${cfg.locale}";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "${cfg.locale}";
      LC_IDENTIFICATION = "${cfg.locale}";
      LC_MEASUREMENT = "${cfg.locale}";
      LC_MONETARY = "${cfg.locale}";
      LC_NAME = "${cfg.locale}";
      LC_NUMERIC = "${cfg.locale}";
      LC_PAPER = "${cfg.locale}";
      LC_TELEPHONE = "${cfg.locale}";
      LC_TIME = "${cfg.locale}";
    };

    home-manager.backupFileExtension = "backup";

    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["root" "@wheel"];
    };
  };
}
