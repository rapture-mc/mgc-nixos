{
  lib,
  config,
  ...
}: let
  cfg = config.megacorp.config.openssh;

  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    mkDefault
    types
    ;
in {
  options.megacorp.config.openssh = {
    enable = mkEnableOption "Whether to enable the SSH daemon";

    bastion = {
      enable = mkEnableOption "Whether to configure as a bastion server";
      logo = mkEnableOption "Whether to show bastion logo on shell startup";
    };

    authorized-ssh-keys = mkOption {
      type = types.listOf types.singleLineStr;
      default = [""];
      description = "List of authorized ssh keys who are allowed to connect using the admin user";
    };

    auto-accept-server-keys = mkEnableOption ''
      Whether to automatically accept remote machines SSH key

      use this option if it isn't plausible to add each known host key to the known_hosts file
    '';
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
        AllowUsers = cfg.authorized-ssh-keys;
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
