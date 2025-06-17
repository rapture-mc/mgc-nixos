{osConfig, lib, ...}: let
  cfg = osConfig.megacorp;
in lib.mkIf cfg.programs.nixvim.enable {
  programs.fastfetch.enable = true;
}
