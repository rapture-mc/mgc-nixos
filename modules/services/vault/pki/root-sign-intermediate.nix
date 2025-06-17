{config}: {
  intermediate = {
    backend = "\${ vault_mount.pki.path }";
    common_name = "${config.megacorp.services.vault.pki.common-name} Intermediate CA";
    csr = "\${ vault_pki_secret_backend_intermediate_cert_request.csr-request.csr }";
    format = "pem_bundle";
    ttl = 15480000;
    issuer_ref = "\${ vault_pki_secret_backend_root_cert.root-cert.issuer_id }";
  };
}
