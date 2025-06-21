{cfg, lib, use-acme-cert}: let
  inherit (lib)
    mkIf;
in {
  security.acme = {
    acceptTerms = true;
    defaults.email = cfg.tls.email;
  };

  systemd.services."acme-${cfg.fqdn}".serviceConfig = mkIf use-acme-cert {SuccessExitStatus = 10;};

  networking.firewall.allowedTCPPorts = [
    443
  ];
}
