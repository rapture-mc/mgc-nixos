{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.megacorp.services.vault;

  inherit
    (lib)
    mkOption
    mkEnableOption
    types
    mkIf
    ;
in {
  options.megacorp.services.vault = {
    enable = mkEnableOption "Whether to enable Hashicorp Vault";

    logo = mkEnableOption "Whether to show vault logo on shell startup";

    gui = mkEnableOption "Whether to enable Vault web GUI inteface";

    open-firewall = mkEnableOption "Whether to open the firewall for the GUI";

    zsh-address-env-variable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to add the VAULT_ADDR environment variable automatically to zsh shell";
    };

    backend = mkOption {
      type = types.str;
      default = "file";
      description = ''
        Which backend storage to use

        See services.vault.storageBackend for possible options
      '';
    };

    address = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "What IP address vault will listen on";
    };
  };

  config = mkIf cfg.enable {
    services.vault = {
      enable = true;
      package =
        if cfg.gui
        then pkgs.vault-bin
        else pkgs.vault;
      storageBackend = cfg.backend;
      address = "${cfg.address}:8200";
      extraConfig = ''
        ${
          if cfg.gui
          then "ui = true"
          else ""
        }
      '';
    };

    environment.systemPackages = [
      pkgs.vault
    ];

    networking.firewall.allowedTCPPorts = (
      if cfg.open-freiwall
      then [
        8200
      ]
      else []
    );

    home-manager.users.${config.megacorp.config.users.admin-user} = _: {
      programs.zsh.sessionVariables.VAULT_ADDR = "http://${cfg.address}:8200";
    };
  };
}
