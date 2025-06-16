{vars}: {
  vault02 = {
    issuer_ref = "\${ vault_pki_secret_backend_issuer.root-2025.issuer_ref }";
    backend = "\${ vault_pki_secret_backend_role.intermediate-role.backend }";
    name = "\${ vault_pki_secret_backend_role.intermediate-role.name }";
    common_name = "vault02.${vars.networking.internalDomain}";
    revoke = true;
    ttl = 7776000;
  };
}
