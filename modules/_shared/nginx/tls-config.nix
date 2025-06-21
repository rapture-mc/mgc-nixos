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

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    virtualHosts."${cfg.fqdn}" = {
      forceSSL = true;
      enableACME = if use-acme-cert then true else false;
      sslCertificate = if !use-acme-cert then cfg.tls.cert-file else null;
      sslCertificateKey = if !use-acme-cert then cfg.tls.cert-key else null;
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
        };
      };
    };
  };
}
