{config}: {
  root-cert = {
    backend = "\${ vault_mount.pki.path }";
    type = "internal";
    common_name = config.megacorp.services.vault.pki.common-name;
    ttl = 315360000;
    issuer_name = "root-issuer";
  };
}
