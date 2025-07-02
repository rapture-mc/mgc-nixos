let
  domain = "megacorp.industries";
in {
  networking = import ./networking.nix;
  keys = import ./keys.nix;

  adminUser = "benny";

  awsZoneID = "/hostedzone/Z02994243ILU2R1YQJ1GF";
  primaryIP = "123.243.147.17";

  primaryDomain = "${domain}";
  guacamoleFQDN = "guacamole.${domain}";
  file-browserFQDN = "file-browser.${domain}";
  semaphoreFQDN = "semaphore.${domain}";
  giteaFQDN = "gitea.${domain}";
  grafanaFQDN = "grafana.${domain}";
  zabbixFQDN = "zabbix.${domain}";
  netboxFQDN = "netbox.${domain}";
  nextcloudFQDN = "nextcloud.${domain}";
  snipe-itFQDN = "snipe-it.${domain}";

  terraformModuleSource = "git::https://github.com/rapture-mc/terraform-libvirt-module.git?ref=40acff807a0ffb1c0da741774c37ebeda90730b7";
}
