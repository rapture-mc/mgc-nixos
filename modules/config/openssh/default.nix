{
  lib,
  config,
  ...
}: let
  cfg = config.megacorp.config.openssh;

  inherit
    (lib)
    mkEnableOption
    mkIf
    mkDefault
    mkOption
    types
    ;
in {
  options.megacorp.config.openssh = {
    enable = mkEnableOption "Whether to enable the SSH daemon";

    bastion = {
      enable = mkEnableOption "Whether to configure as a bastion server";
      logo = mkEnableOption "Whether to show bastion logo on shell startup";
    };

    auto-accept-server-keys = mkEnableOption ''
      Whether to automatically accept remote machines SSH key

      use this option if it isn't plausible to add each known host key to the known_hosts file
    '';

    allowed-groups = mkOption {
      type = types.listOf types.str;
      description = ''
        A list of groups that are permitted to connect to the SSH daemon (wheel members are always permitted)

        This is necessary when megacorp.config.system.ad-domain is enabled as AD users won't be able to connect unless they are members of a group that is defined using this option.
      '';
      default = [];
    };
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PasswordAuthentication =
          if cfg.bastion.enable
          then true
          else false;
        PermitRootLogin = mkDefault "no";
        AllowGroups = [
          "wheel"
        ] ++ cfg.allowed-groups;
      };
    };

    # Required for oh-my-tmux ssh sessions to work correctly
    programs.ssh.extraConfig = ''
      SetEnv TERM=screen-256color
      ${
        if cfg.auto-accept-server-keys
        then "StrictHostKeyChecking=accept-new"
        else ""
      }
    '';
  };
}
