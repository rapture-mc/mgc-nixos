{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.megacorp.config;
  inherit
    (lib)
    mkIf
    ;
in {
  config = mkIf (cfg.desktop.enable || cfg.hyprland.enable) {
    networking.networkmanager.enable = true;

    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        nerd-fonts.terminess-ttf
        noto-fonts-emoji
      ];
    };

    security.rtkit.enable = true;

    services = {
      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse.enable = true;
      };
    };
  };
}
