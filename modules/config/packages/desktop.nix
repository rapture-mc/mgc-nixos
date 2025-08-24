{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.megacorp.config.packages;

  inherit
    (lib)
    mkIf
    ;
in
  mkIf cfg.enable (with pkgs; {
    environment.systemPackages = lib.mkIf (config.megacorp.config.desktop.enable || config.megacorp.config.hyprland.enable) [
      chromium
      firefox
      keepassxc
      libreoffice
      networkmanager
      remmina
      signal-desktop
      thunderbird
      vlc
    ];
  })
