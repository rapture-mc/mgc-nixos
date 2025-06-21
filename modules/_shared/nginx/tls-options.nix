{lib}: let
  inherit
    (lib)
    mkEnableOption
    mkOption
    types
    ;
in {
  enable = mkEnableOption ''
    Whether to enable TLS.

    If this option is set to true and tls.cert-key or tls.cert-file are null, a signed certifiacate will be requested using ACME. If the proper networking/DNS are not setup a self-signed certificate will be used instead.
  '';

  cert-key = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "Path to the TLS certificate private key file";
  };

  cert-file = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "Path to the TLS certificate file";
  };

  email = mkOption {
    type = types.str;
    default = "someone@somedomain.com";
    description = ''
      The email to use for automatic SSL certificates
      This email will also get SSL certificate renewal email notifications
    '';
  };
}
