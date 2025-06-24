{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.megacorp.services.restic;

  makeRepoGroupWriteable = pkgs.writeShellScriptBin "makeRepoGroupWriteable" ''
    if [ -z "$1" ]; then
      echo "Error: You must pass a directory as a paramater to this command... Exiting!"
      exit 1
    elif [ "$(id -u)" -ne 0 ]; then
      echo "Error: This command must be run with sudo... Exiting!"
      exit 1
    else
      echo "Ensuring files within $1 inherit the group belonging to $1..."
      find $1 -type d -exec chmod g+s '{}' \;
      echo -e "Done!\n"

      echo "Recursively setting group read/write permissions on $1..."
      chmod -R g+rw $1
      echo -e "Done!\n"
    fi
  '';

  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in {
  options.megacorp.services.restic = {
    sftp-server = {
      enable = mkEnableOption "Enable Restic server";

      logo = mkEnableOption "Whether to show Restic logo on shell startup";

      authorized-keys = mkOption {
        type = types.listOf types.str;
        default = [""];
        description = "A list of authorized SSH keys that can connect via SSH to the restic user account";
      };
    };

    backups = {
      enable = mkEnableOption "Enable Restic backups";

      run-as = mkOption {
        type = types.str;
        default = "root";
        description = ''
          Who the backup job should run as
          Default is to run as root
        '';
      };

      target-folders = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          The folders to backup. These folders will be backed up as well as the below default folders:
            - /home/<admin-user>/.ssh
            - /home/<admin-user>/.config/sops
            - /etc/ssh/ssh_host_ed25519_key
            - /etc/ssh/ssh_host_ed25519_key.pub
        '';
      };

      target-host = mkOption {
        type = types.str;
        default = "";
        description = ''
          The target host where the backups will be uploaded to
          You must have passwordless SSH access to it
          Can either by a DNS name or IP address
        '';
      };

      target-path = mkOption {
        type = types.str;
        default = "/var/lib/restic-backup";
        description = ''
          The target path on the host where the repository is located
          If the repostiory doesn't exist it will be created automatically without password protection
        '';
      };

      repository-name = mkOption {
        type = types.str;
        default = "default";
        description = "The name of the repository directory on the remote host";
      };

      repository-password-file = mkOption {
        type = types.str;
        default = "/run/secrets/restic-repo-password";
        description = "The path to the file containing the password for the restic repository";
      };

      frequency = mkOption {
        type = types.str;
        default = "Sat *-*-* 00:00:00";
        description = ''
          How often the backups should run in systemd.timer format
          Default is every Saturday at 12:00AM
        '';
      };
    };
  };

  config = {
    users = mkIf cfg.sftp-server.enable {
      users.restic-backup = {
        home = "/var/lib/restic-backup";
        shell = pkgs.bash;
        createHome = true;
        homeMode = "770";
        group = "restic-backup";
        isSystemUser = true;
        openssh.authorizedKeys.keys = cfg.sftp-server.authorized-keys;
      };

      groups.restic-backup.members = [
        "restic"
        "${config.megacorp.config.users.admin-user}"
      ];
    };

    environment.systemPackages = mkIf cfg.sftp-server.enable [
      pkgs.restic
      makeRepoGroupWriteable
    ];

    services.restic.backups = mkIf cfg.backups.enable {
      default = {
        initialize = true;
        user = cfg.backups.run-as;
        passwordFile = cfg.backups.repository-password-file;
        repository = "sftp:restic-backup@${cfg.backups.target-host}:${cfg.backups.target-path}/${cfg.backups.repository-name}";
        paths =
          [
            "/home/${config.megacorp.config.users.admin-user}/.ssh"
            "/home/${config.megacorp.config.users.admin-user}/.config/sops"
            "/root/.ssh"
            "/etc/ssh/ssh_host_ed25519_key"
            "/etc/ssh/ssh_host_ed25519_key.pub"
          ]
          ++ cfg.backups.target-folders;

        timerConfig = {
          OnCalendar = cfg.backups.frequency;
          Persistent = true;
        };
      };
    };
  };
}
