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
  options.megacorp.config.users = {
    enable = mkEnableOption "Whether to enable Megacorp defined users";

    shell = mkOption {
      type = types.enum [
        "zsh"
        "nushell"
      ];
      default = "zsh";
      description = ''
        The shell to use for Megacorp users

        Either zsh or nushell
      '';
    };

    admin-user = mkOption {
      type = types.str;
      default = "megaroot";
      description = "Default admin user";
    };

    regular-user = {
      enable = mkEnableOption "Whether to enable the user account";

      name = mkOption {
        type = types.str;
        default = "user";
        description = "Default admin user";
      };
    };
  };

  config = mkIf cfg.enable {
    programs.zsh.enable = true;

    home-manager.users = mkMerge [
      {
        ${cfg.admin-user} = {
          imports = [../../home-manager/default.nix];
        };
      }

      (mkIf cfg.regular-user.enable {
        ${cfg.regular-user.name} = {
          imports = [../../home-manager/default.nix];
        };
      })
    ];

    users.users = mkMerge [
      {
        ${cfg.admin-user} = {
          isNormalUser = true;
          initialPassword = "changeme";
          shell = pkgs.${cfg.shell};
          extraGroups = ["wheel"];
        };
      }

      (mkIf cfg.regular-user.enable {
        ${cfg.regular-user.name} = {
          isNormalUser = true;
          initialPassword = "changeme";
          shell = pkgs.${cfg.shell};
        };
      })
    ];
  };
}
