{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.megacorp.config.desktop;

  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;

  cyberpunk =
    if cfg.enable && cfg.theme == "cyberpunk"
    then true
    else false;

  win-95 =
    if cfg.enable && cfg.theme == "win-95"
    then true
    else false;
in {
  imports = [
    (mkIf cfg.enable (import ../../_shared/desktop {inherit pkgs;}))
    (mkIf cyberpunk (import ./cyberpunk {inherit pkgs;}))
    (mkIf win-95 (import ./win-95 {inherit pkgs;}))
  ];

  options.megacorp.config.desktop = {
    enable = mkEnableOption "Whether to enable desktop environment";

    theme = mkOption {
      description = "Which desktop theme to use";
      type = types.enum [
        "cyberpunk"
        "win-95"
      ];
      default = "cyberpunk";
    };

    xrdp = mkEnableOption "Whether to enable RDP server";
  };

  config = {
    services.xrdp = mkIf cfg.xrdp {
      enable = true;
      openFirewall = true;
      defaultWindowManager = "startplasma-x11";
    };
  };
}
