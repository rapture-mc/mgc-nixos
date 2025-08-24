{
  lib,
  config,
  ...
}: let
  cfg = config.megacorp.services.tailscale.client;

  inherit
    (lib)
    mkEnableOption
    mkIf
    ;
in {
  options.megacorp.services.tailscale.enable = mkEnableOption "Whether to enable the tailscale client";

  config = mkIf cfg.enable {
    services.tailscale.enable = true;

    networking.firewall = {
      checkReversePath = "loose";
      trustedInterfaces = [
        "tailscale0"
      ];
      allowedUDPPorts = [
        41641
      ];
    };
  };
}
