{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.megacorp.services.password-store;

  inherit
    (lib)
    mkEnableOption
    mkIf
    ;
in {
  options.megacorp.services.password-store = {
    enable = mkEnableOption "Enable Password Store";

    logo = mkEnableOption "Whether to show password vault logo on shell startup";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.pass];

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    services.openssh.settings.X11Forwarding = true;
  };
}
