{vars}: {
  megacorp.services.restic.backups = {
    enable = true;
    target-host = "MGC-DRW-RST01";
  };

  services = {
    openssh.knownHosts = vars.keys.knownHosts;
  };
}
