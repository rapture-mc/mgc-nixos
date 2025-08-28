{
  lib,
  config,
  pkgs,
  modulesPath,
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
  # Currently waiting on https://github.com/NixOS/nixpkgs/pull/290485 to merge, in the interim we disable existing module and import the updated module 
  disabledModules = [
    "${modulesPath}/services/networking/syncthing.nix"
  ];

  # Here we import the updated syncthing module
  imports = [
    ./guiPasswordFile-PR.nix
  ];

  options.megacorp.services.syncthing = {
    enable = mkEnableOption "Enable syncthing";

    user = mkOption {
      type = types.str;
      description = "The user to run the syncthing service under";
    };

    gui = {
      enable = mkEnableOption ''
        Whether to enable the GUI. Will be available at the hosts IP on port 8384.

        Default username: syncthing
      '';

      password-file = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Full path to the file containing the GUI password";
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
        guiPasswordFile = cfg.gui.password-file;
        user = cfg.user;
        group = "users";
        guiAddress =
          if cfg.gui.enable
          then "0.0.0.0:8384"
          else "127.0.0.1:8384";
        overrideDevices = true;
        overrideFolders = true;
        dataDir = "/home/${cfg.user}";
        configDir = "/home/${cfg.user}/.config/syncthing";
        settings = {
          options.urAccepted = -1;
          gui = mkIf cfg.gui.enable {
            user = "syncthing";
            password = mkIf (cfg.gui.password-file != null) "changeme";
            useTLS = true;
          };
          devices = cfg.devices;
          folders = cfg.folders;
        };
      };
    };
  };
}
