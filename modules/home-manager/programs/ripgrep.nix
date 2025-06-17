{osConfig, lib, ...}: let
  cfg = osConfig.megacorp;

  inherit (lib)
    mkIf
    mkEnableOption;
in {
  option.megacorp.programs.ripgrep = {
    enable = mkEnableOption "Enable ripgrep";
  };

  config = mkIf (cfg.programs.nixvim.enable || cfg.programs.ripgrep.enable) {
    programs.fastfetch.enable = true;
  };
}
