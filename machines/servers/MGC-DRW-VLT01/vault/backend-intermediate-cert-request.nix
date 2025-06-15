{vars}: {
  csr-request = {
    backend = "\${ vault_mount.pki_int.path }";
    type = "internal";
    common_name = "${vars.networking.internalDomain} Intermediate Authority";
  };
}
