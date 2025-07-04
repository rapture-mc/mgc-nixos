{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.megacorp.config.users;

  inherit
    (lib)
    mkEnableOption
    mkOption
    mkMerge
    mkIf
    types
    ;
in {
  options.megacorp.config.users = mkOption {
    type = types.nullOr types.attrsOf (
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
          };
        }
      )
    );
    default = null;
  };

  config = mkIf (cfg.users != null) {
    programs.zsh.enable = true;

    home-manager.users = lib.mapAttrs'
      (userName: userConfig: {
        ${userName} = {
          imports = [../../home-manager];
        };
      }) cfg;

    users.users = lib.mapAttrs'
      (userName: userConfig: {
        ${userName} = {
          isNormalUser = true;
          initialPassword = "changeme";
          shell = pkgs.${userConfig.shell};
          extraGroups = mkIf userConfig.sudo [ "wheel" ];
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
