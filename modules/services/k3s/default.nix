{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.megacorp.services.k3s;

  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;

  createKubeConfig = pkgs.writeShellScriptBin "createKubeConfig" ''
    mkdir -p ~/.kube
    if [ "$(id -u)" -ne 0 ]; then
      echo "Error: This command must be run with sudo... Exiting!"
      exit 1
    elif [ -f /home/$SUDO_USER/.kube/config ]; then
      echo "Kubectl config file already exists... Skipping"
      exit 1
    else
      echo "Copying /etc/rancher/k3s/k3s.yaml to /home/$SUDO_USER/.kube/config"
      sudo cp /etc/rancher/k3s/k3s.yaml /home/$SUDO_USER/.kube/config
      echo -e "Done!\n"

      echo "Setting correct ownership permissions on kubectl config..."
      sudo chown $SUDO_USER:users /home/$SUDO_USER/.kube/config
      echo -e "Done!\n"
    fi
  '';
in {
  options.megacorp.services.k3s = {
    enable = mkEnableOption "Enable k3s";

    cluster-init = mkEnableOption "Whether to initialize the cluster";

    logo = mkEnableOption "Whether to enable the k3s logo";

    role = mkOption {
      type = types.str;
      default = "server";
      description = "The k3s role (either 'server' or 'agent')";
    };

    token-file = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "The path to the file containing the k3s token";
    };

    server-ip = mkOption {
      type = types.str;
      default = "";
      description = "The k3s master server IP";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [
        6443
        2379
        2380
        7946
      ];

      allowedUDPPorts = [
        8472
        7946
      ];
    };

    environment = mkIf (cfg.role == "server" && cfg.cluster-init == true) {
      sessionVariables = {
        KUBECONFIG = "$HOME/.kube/config";
      };

      systemPackages = [
        pkgs.k9s
        createKubeConfig
      ];
    };

    services = {
      rpcbind.enable = true;

      k3s = {
        enable = true;
        clusterInit = cfg.cluster-init;
        role = cfg.role;
        tokenFile = cfg.token-file;
        serverAddr = if cfg.server-ip != null then "https://${cfg.server-ip}:6443" else "";
      };
    };

    boot.supportedFilesystems = ["nfs"];
  };
}
