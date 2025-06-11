{
  lib,
  config,
  ...
}: let
  cfg = config.megacorp.config.networking.wireless;
in {
  options.megacorp.config.networking.wireless = with lib; {
    enable = mkEnableOption ''
      Enable wireless capabilities

      Not required if megacorp.config.desktop.enable is true
    '';
  };

  config = lib.mkIf cfg.enable {
    networking.wireless = {
      enable = true;
    };
  };
}
