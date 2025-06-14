{
  root-2025 = {
    backend = "\${ vault_mount.pki.path }";
    issuer_ref = "\${ vault_pki_secret_backend_root_cert.root-cert-2025.issuer_id }";
    issuer_name = "\${ vault_pki_secret_backend_root_cert.root-cert-2025.issuer_name }";
    revocation_signature_algorithm = "SHA256WithRSA";
  };
}
