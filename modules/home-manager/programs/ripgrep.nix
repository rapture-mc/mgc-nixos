{osConfig, lib, ...}: let
  cfg = osConfig.megacorp;
in {
  config = lib.mkIf cfg.programs.nixvim.enable {
    programs.fastfetch.enable = true;
  };
}
