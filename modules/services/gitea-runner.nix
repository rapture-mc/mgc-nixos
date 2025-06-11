{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.megacorp.services.gitea-runner;

  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in {
  options.megacorp.services.gitea-runner = {
    enable = mkEnableOption "Enable Gitea runner";

    name = mkOption {
      type = types.str;
      default = "default";
      description = "The name of the Gitea runner";
    };

    url = mkOption {
      type = types.str;
      default = "";
      description = ''
        The Gitea instance IP/domain name

        Example: gitea.example.com
      '';
    };

    token-file = mkOption {
      type = types.path;
      default = /run/secrets/gitea-token;
      description = ''
        The environment file containing the token variable

        The contents of the file should be in the format of "TOKEN=<TOKEN-STRING>"
      '';
    };

    labels = mkOption {
      type = types.listOf types.str;
      default = ["native:host"];
      description = ''
        The environment file containing the token variable

        The contents of the file should be in the format of "TOKEN=<TOKEN-STRING>"
      '';
    };

    packages = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
        bash
        coreutils
        curl
        deploy-rs
        gawk
        gitMinimal
        gnused
        hostname
        nix
        nodejs
        openssh
        wget
      ];
      description = "List of packages to make available to the runner";
    };
  };

  config = mkIf cfg.enable {
    services.gitea-actions-runner.instances.${cfg.name} = {
      enable = true;
      url = "https://${cfg.url}";
      tokenFile = cfg.token-file;
      name = "${cfg.name}";
      labels = cfg.labels;
      hostPackages = cfg.packages;
    };
  };
}
