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
      type = types.path;
      default = /run/secrets/kube-token;
      description = "The path to the file containing the k3s token";
    };

    server-ip = mkOption {
      type = types.str;
      default = "127.0.0.1";
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

    environment = mkIf (cfg.role == "server") {
      sessionVariables = {KUBECONFIG = "$HOME/.kube/config";};
      systemPackages = [pkgs.k9s];
    };

    services = {
      k3s = {
        enable = true;
        clusterInit = cfg.cluster-init;
        role = cfg.role;
        tokenFile = cfg.token-file;
        serverAddr = "https://${cfg.server-ip}:6443";
      };
      rpcbind.enable = true;
    };

    boot.supportedFilesystems = ["nfs"];
  };
}
