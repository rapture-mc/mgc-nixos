{config}: {
  config-urls = {
    backend = "\${ vault_mount.pki.path }";
    issuing_certificates = ["http://${config.megacorp.services.vault.address}/v1/pki/ca"];
    crl_distribution_points = ["http://${config.megacorp.services.vault.address}/v1/pki/crl"];
  };
}
