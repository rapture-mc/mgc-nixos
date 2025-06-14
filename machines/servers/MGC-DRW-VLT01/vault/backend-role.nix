{
  role = {
    backend = "\${ vault_mount.pki.path }";
    name = "2025-servers-role";
    ttl = 86400;
    allow_ip_sans = true;
    key_type = "rsa";
    key_bits = 4096;
    allowed_domains = [
      "megacorp.industries"
    ];
    allow_subdomains = true;
    allow_any_name = true;
  };
}
