{vars}: {
  config-urls = {
    backend = "\${ vault_mount.pki.path }";
    issuing_certificates = ["http://${vars.networking.hostsAddr.MGC-DRW-VLT01.eth.ipv4}:8200/v1/pki/ca"];
    crl_distribution_points = ["http://${vars.networking.hostsAddr.MGC-DRW-VLT01.eth.ipv4}:8200/v1/pki/crl"];
  };
}
