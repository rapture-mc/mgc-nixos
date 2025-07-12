{vars}: {
  services.zabbix.agent = {
    enable = true;
    server = vars.networking.hostsAddr.MGC-DRW-MON01.eth.ipv4;
  };
}
