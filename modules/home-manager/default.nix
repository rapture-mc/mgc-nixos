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
        && osConfig.megacorp.config.desktop.theme == "cyberpunk"
        && !osConfig.megacorp.config.hyprland.enable
      then ./config/desktop/cyberpunk
      else ./config/desktop/none.nix
    )
    (
      if
        osConfig.megacorp.config.desktop.enable
        && osConfig.megacorp.config.desktop.theme == "win-95"
        && !osConfig.megacorp.config.hyprland.enable
      then ./config/desktop/win-95
      else ./config/desktop/none.nix
    )
    (
      if osConfig.megacorp.config.hyprland.enable
      then ./config/desktop/hyprland
      else ./config/desktop/none.nix
    )
  ];

  home.stateVersion = osConfig.system.stateVersion;

  programs.home-manager.enable = true;
}
