{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.megacorp.programs.pass;

  inherit
    (lib)
    mkEnableOption
    mkIf
    ;
in {
  options.megacorp.programs.pass.enable = mkEnableOption "Enable Password Store";

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.pass
    ];

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    services.openssh.settings.X11Forwarding = true;
  };
}
