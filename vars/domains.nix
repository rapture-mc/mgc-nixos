let
  domain = "megacorp.industries";
in {
  primaryDomain = "${domain}";
  internalDomain = "prod.${domain}";

  # Domains publicly resolveable
  guacamoleFQDN = "guacamole.${domain}";
  file-browserFQDN = "file-browser.${domain}";
  nextcloudFQDN = "nextcloud.${domain}";

  # Domains used internally (non publicly resolveable)
  semaphoreFQDN = "semaphore.prod.${domain}";
  grafanaFQDN = "grafana.prod.${domain}";
  zabbixFQDN = "zabbix.prod.${domain}";
  netboxFQDN = "netbox.prod.${domain}";
  snipe-itFQDN = "snipe-it.prod.${domain}";
}
