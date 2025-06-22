{
  networking = import ./networking.nix;
  keys = import ./keys.nix;

  adminUser = "benny";

  guacamoleFQDN = "guacamole.megacorp.industries";
  file-browserFQDN = "file-browser.megacorp.industries";
  semaphoreFQDN = "semaphore.megacorp.industries";
  giteaFQDN = "git.megacorp.industries";
  grafanaFQDN = "grafana.megacorp.industries";
  zabbixFQDN = "zabbix.megacorp.industries";
  netboxFQDN = "netbox.megacorp.industries";

  terraformModuleSource = "git::https://github.com/rapture-mc/terraform-libvirt-module.git?ref=40acff807a0ffb1c0da741774c37ebeda90730b7";
}
