{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.megacorp.services.syncthing;

  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in {
  options.megacorp.services.syncthing = {
    enable = mkEnableOption "Enable syncthing";

    user = mkOption {
      type = types.str;
      description = "The user to run the syncthing service under";
    };

    gui = {
      enable = mkEnableOption ''
      Whether to enable the GUI. Will be available at the hosts IP on port 8384.

      NOTE: GUI will be unprotected until you set a password.
      '';

      admin-password-file = mkOption {
        type = types.path;
        default = "";
        description = "The absolute path to a password file containing the LDAP admin password";
      };
    };

    devices = mkOption {
      type = types.attrs;
      description = ''
        Devices that Syncthing should be able to communicate with.

        See services.syncthing.settings.devices (in nixpkgs) for more info

        E.g:
        devices = {
          device1 = {
            id = "<DEVICE-ID>";
            autoAcceptFolders = true;
          };
        };
      '';
      default = {};
    };

    folders = mkOption {
      type = types.attrs;
      description = ''
        Folders to be shared by Syncthing.

        See services.syncthing.settings.folders (in nixpkgs) for more info

        E.g:
        folders = {
          "Documents" = {
            devices = "device1";
            path = /home/<USER>/Documents;
          };
        };
      '';
      default = {};
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.syncthing];

    networking.firewall = {
      allowedTCPPorts =
        [
          22000
        ]
        ++ (
          if cfg.gui.enable
          then [8384]
          else []
        );

      allowedUDPPorts = [
        22000
        21027
      ];
    };

    # systemd.services.insert-syncthing-gui-password = mkIf cfg.gui.enable {
    #   wantedBy = [
    #     "multi-user.target"
    #   ];
    #
    #   serviceConfig = {
    #     Type = "oneshot";
    #     User = "root";
    #     Group = "root";
    #   };
    #
    #   script = ''
    #     if [[ -r ${cfg.gui.admin-password-file} ]]; then
    #       umask 0077
    #       temp_conf="$(mktemp)"
    #       cp ${config.environment.etc."guacamole/guacamole.properties".source} $temp_conf
    #       printf 'ldap-search-bind-password = %s\n' "$(cat ${cfg.gui.admin-password-file})" >> $temp_conf
    #       mv -fT "$temp_conf" /etc/guacamole/guacamole.properties
    #       chown root:tomcat /etc/guacamole/guacamole.properties
    #       chmod 750 /etc/guacamole/guacamole.properties
    #     fi
    #   '';
    # };

    services = {
      syncthing = {
        enable = true;
        group = "users";
        user = cfg.user;
        guiAddress =
          if cfg.gui.enable
          then "0.0.0.0:8384"
          else "127.0.0.1:8384";
        dataDir = "/home/${cfg.user}/Documents";
        configDir = "/home/${cfg.user}/.config/syncthing";
        overrideDevices = true;
        overrideFolders = true;
        settings = {
          options.urAccepted = -1;
          devices = cfg.devices;
          folders = cfg.folders;
        };
      };
    };
  };
}
