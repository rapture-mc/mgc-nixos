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

    # user = mkOption {
    #   type = types.str;
    #   description = "The user to run the syncthing service under";
    # };

    gui = {
      enable = mkEnableOption ''
      Whether to enable the GUI. Will be available at the hosts IP on port 8384.

      NOTE: GUI will be unprotected until you set a password.
      '';

      hashed-admin-password-file = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          The absolute path to a password file containing the bcrypt hashed admin password.

          Hash can be generated using "htpasswd -bnBC 10 "" PASSWORD | tr -d ':'" from the apacheHttpd nix package.
        '';
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
          if cfg.gui.enable
          then [8384]
          else []
        );

      allowedUDPPorts = [
        22000
        21027
      ];
    };

    systemd.services.inject-syncthing-gui-password = mkIf (cfg.gui.enable && cfg.gui.hashed-admin-password-file != null) {
      wantedBy = [
        "syncthing.service"
      ];

      after = [
        "syncthing.service"
      ];

      bindsTo = [
        "syncthing.service"
      ];

      partOf = [
        "syncthing.service"
      ];

      serviceConfig = {
        Type = "oneshot";
        User = "root";
        Group = "root";
        # ExecStartPost = "${pkgs.systemdUkify}/bin/systemctl restart syncthing.service";
      };

      script = ''
        if [[ -r ${cfg.gui.hashed-admin-password-file} ]]; then
          echo "Updating syncthing GUI password"
          SYNCTHING_PASSWORD=$(< ${cfg.gui.hashed-admin-password-file})
          ${pkgs.syncthing}/bin/syncthing generate --gui-password=$SYNCTHING_PASSWORD
        fi
      '';
    };

    services = {
      syncthing = {
        enable = true;
        guiAddress =
          if cfg.gui.enable
          then "0.0.0.0:8384"
          else "127.0.0.1:8384";
        overrideDevices = true;
        overrideFolders = true;
        settings = {
          options.urAccepted = -1;
          gui.user = "syncthing";
          devices = cfg.devices;
          folders = cfg.folders;
        };
      };
    };
  };
}
