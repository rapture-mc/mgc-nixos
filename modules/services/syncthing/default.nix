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

    gui = mkEnableOption ''
      Whether to enable the GUI. Will be available at the hosts IP on port 8384.

      Default username: syncthing
      Default password: changeme
    '';

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
    environment.systemPackages = [
      pkgs.syncthing
    ];

    networking.firewall = {
      allowedTCPPorts =
        [
          22000
        ]
        ++ (
          if cfg.enable
          then [8384]
          else []
        );

      allowedUDPPorts = [
        22000
        21027
      ];
    };

    systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";

    services = {
      syncthing = {
        enable = true;
        guiAddress =
          if cfg.gui
          then "0.0.0.0:8384"
          else "127.0.0.1:8384";
        overrideDevices = true;
        overrideFolders = true;
        settings = {
          options.urAccepted = -1;
          gui = mkIf cfg.gui {
            user = "syncthing";
            password = "changeme";
            tls = "true";
          };
          devices = cfg.devices;
          folders = cfg.folders;
        };
      };
    };
  };
}
