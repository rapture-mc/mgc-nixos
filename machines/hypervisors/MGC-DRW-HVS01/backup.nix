{vars}: {
  megacorp.services.restic.backups = {
    enable = true;
    target-host = "MGC-DRW-RST01";
    target-folders = [
      "/var/lib/libvirt/images/MGC-DRW-GUC01.qcow2"
      "/var/lib/libvirt/images/MGC-DRW-GUC01.xml"
    ];
  };

  services = {
    openssh.knownHosts = vars.keys.knownHosts;
  };
}
