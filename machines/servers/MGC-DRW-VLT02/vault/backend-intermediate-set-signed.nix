{
  intermediate = {
    backend = "\${ vault_mount.pki_int.path }";
    certificate = "\${ vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate }";
  };
}
