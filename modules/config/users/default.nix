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
    type = types.nullOr (types.attrsOf (
      types.submodule (
        {name, ...}: {
          options = {
            name = mkOption {
              type = types.str;
              default = name;
              description = "The name of the user";
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

            authorized-ssh-keys = mkOption {
              type = types.listOf types.singleLineStr;
              default = [""];
              description = "List of authorized ssh keys who are allowed to connect using the admin user";
            };
          };
        }
      )
    ));
    default = null;
  };

  config = mkIf (cfg != null) {
    programs.zsh.enable = true;

    home-manager.users = lib.mapAttrs'
      (userName: userConfig: {
        name = userName;
        value = {
          imports = [../../home-manager];
        };
      }) cfg;

    users.users = lib.mapAttrs'
      (userName: userConfig: {
        name = userName;
        value = {
          isNormalUser = true;
          initialPassword = "changeme";
          shell = pkgs.${userConfig.shell};
          extraGroups = mkIf userConfig.sudo [ "wheel" ];
          openssh.authorizedKeys = ${userConfig.authorized-ssh-keys};
        };
      }) cfg;
      

    # users.users = mkMerge [
    #   {
    #     ${cfg.admin-user} = {
    #       isNormalUser = true;
    #       initialPassword = "changeme";
    #       shell = pkgs.${cfg.shell};
    #       extraGroups = ["wheel"];
    #     };
    #   }
    #
    #   (mkIf cfg.regular-user.enable {
    #     ${cfg.regular-user.name} = {
    #       isNormalUser = true;
    #       initialPassword = "changeme";
    #       shell = pkgs.${cfg.shell};
    #     };
    #   })
    # ];
  };
}
