{vars}: {
  root-cert-2025 = {
    backend = "\${ vault_mount.pki.path }";
    type = "internal";
    common_name = vars.networking.internalDomain;
    ttl = 315360000;
    issuer_name = "root-2025";
  };
}
