{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.megacorp.services.controller;

  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in {
  options.megacorp.services.controller = {
    agent.enable = mkEnableOption "Enable controller agent component";

    server = {
      enable = mkEnableOption "Enable controller server component";

      public-key = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "The public SSH key for the controller server user";
      };
    };
  };

  config = {
    environment.systemPackages = mkIf cfg.server.enable [pkgs.deploy-rs];

    users.users.controller = mkIf cfg.agent.enable {
      isNormalUser = true;
      extraGroups = ["wheel"];
      openssh.authorizedKeys.keys = cfg.server.public-key;
    };

    security.sudo.extraRules = mkIf cfg.agent.enable [
      {
        users = ["controller"];
        commands = [
          {
            command = "ALL";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];
  };
}
