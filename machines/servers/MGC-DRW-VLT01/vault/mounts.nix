{
  pki = {
    path = "pki";
    type = "pki";
    description = "PKI root mount";
    default_lease_ttl_seconds = 86400;
    max_lease_ttl_seconds = 315360000; # Equal to 87,600 hours
  };

  pki_int = {
    path = "pki_int";
    type = "pki";
    description = "PKI intermediate mount";
    default_lease_ttl_seconds = 86400;
    max_lease_ttl_seconds = 157680000; # Equal to 43,800 hours
  };
}
