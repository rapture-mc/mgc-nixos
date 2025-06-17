{config}: {
  csr-request = {
    backend = "\${ vault_mount.pki_int.path }";
    type = "internal";
    common_name = "${config.megacorp.services.vault.pki.common-name} Intermediate Authority";
  };
}
