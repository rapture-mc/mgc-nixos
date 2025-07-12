let
  domain = "megacorp.industries";
in {
  primaryDomain = "${domain}";
  guacamoleFQDN = "guacamole.${domain}";
  file-browserFQDN = "file-browser.${domain}";
  semaphoreFQDN = "semaphore.prod.${domain}";
  grafanaFQDN = "grafana.prod.${domain}";
  zabbixFQDN = "zabbix.prod.${domain}";
  netboxFQDN = "netbox.prod.${domain}";
  nextcloudFQDN = "nextcloud.${domain}";
  snipe-itFQDN = "snipe-it.prod.${domain}";
}
