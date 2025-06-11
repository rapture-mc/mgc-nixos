{
  osConfig,
  lib,
  ...
}: {
  programs = lib.mkIf (osConfig.megacorp.config.desktop.enable || osConfig.megacorp.config.hyprland.enable) {
    kitty = {
      enable = true;
      shellIntegration.enableZshIntegration = true;
      themeFile = "Cyberpunk-Neon";
      extraConfig = ''
        background_opacity 0.8
      '';
      font = {
        size = 13.0;
        name = "Terminus";
      };
    };
  };
}
