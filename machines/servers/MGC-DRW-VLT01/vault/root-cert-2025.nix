{
  root-cert-2025 = {
    backend     = "\${ vault_mount.pki.path }";
    type        = "internal";
    common_name = "megacorp.industries";
    ttl         = 315360000;
    issuer_name = "root-2025";
  };
}
