{
  pki = {
    path = "pki";
    type = "pki";
    description = "PKI mount";
    default_lease_ttl_seconds = 86400;
    max_lease_ttl_seconds = 315360000;  # Equal to 87,600 hours
  };
}
