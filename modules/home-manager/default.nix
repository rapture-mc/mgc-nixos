{osConfig, ...}: {
  imports = [
    ./config/desktop/applications.nix
    ./programs/btop.nix
    ./programs/kitty.nix
    ./programs/nushell.nix
    ./programs/rofi.nix
    ./programs/tmux.nix
    ./programs/zsh.nix
    (
      if
        osConfig.megacorp.config.desktop.enable
        && !osConfig.megacorp.config.hyprland.enable
      then ./config/desktop/plasma.nix
      else ./config/desktop/none.nix
    )
    (
      if osConfig.megacorp.config.hyprland.enable
      then ./config/desktop/hyprland.nix
      else ./config/desktop/none.nix
    )
  ];

  home.stateVersion = osConfig.system.stateVersion;

  programs.home-manager.enable = true;
}
