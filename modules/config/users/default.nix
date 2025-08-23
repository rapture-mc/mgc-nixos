{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.megacorp.config.users;

  inherit
    (lib)
    mkOption
    mkIf
    types
    ;
in {
  options.megacorp.config.users = mkOption {
    default = null;
    type = types.nullOr (types.attrsOf (
      types.submodule (
        {name, ...}: {
          options = {
            name = mkOption {
              type = types.str;
              default = name;
              description = "The name of the user";
            };

            enable = mkOption {
              type = types.bool;
              default = true;
              description = "Whether the user account should be enabled";
            };

            shell = mkOption {
              type = types.enum [
                "bash"
                "zsh"
                "nushell"
              ];
              default = "zsh";
              description = "The shell of the user";
            };

            sudo = mkOption {
              type = types.bool;
              default = false;
              description = "Whether to grant the user sudo privilliges";
            };

            extra-groups = mkOption {
              type = types.listOf types.str;
              default = [];
              description = "Extra groups to be a member of";
            };

            authorized-ssh-keys = mkOption {
              type = types.listOf types.singleLineStr;
              default = [""];
              description = "List of public ssh keys who are authorized to connect to this user account over SSH";
            };
          };
        }
      )
    ));
  };

  config = mkIf (cfg != null) {
    programs.zsh.enable = true;

    home-manager.users =
      lib.mapAttrs'
      (userName: userConfig: {
        name = userName;
        value = {
          imports = [../../home-manager];
        };
      })
      cfg;

    users.users =
      lib.mapAttrs'
      (userName: userConfig: {
        name = userName;
        value = {
          enable = userConfig.enable;
          isNormalUser = true;
          initialPassword = "changeme";
          shell = pkgs.${userConfig.shell};
          extraGroups =
            userConfig.extra-groups
            ++ (
              if userConfig.sudo
              then ["wheel"]
              else []
            );
          openssh.authorizedKeys.keys = userConfig.authorized-ssh-keys;
        };
      })
      cfg;
  };
}
