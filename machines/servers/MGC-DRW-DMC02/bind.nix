{pkgs, vars}: let
  internal-domain = "prod.megacorp.industries";
  email-contact = "ict.megacorp.industries";
  name-server = "mgc-drw-dmc02";
in {
  networking.firewall.allowedUDPPorts = [
    53
  ];

  services.bind = {
    enable = true;
    forwarders = [
      "8.8.8.8"
      "8.8.4.4"
    ];
    cacheNetworks = [
      "192.168.1.0/24"
      "127.0.0.1"
    ];
    zones."${internal-domain}" = {
      master = true;
      file = pkgs.writeText "zone-${internal-domain}" ''
        $ORIGIN ${internal-domain}.
        $TTL    1h
        @                 IN              SOA         ${name-server}.${internal-domain}. ${email-contact} (
                                                      2025062401  ; 2025-06-24 Revision 01
                                                      7200        ; Slave servers should check for updates every 2 hours
                                                      3600        ; Slave servers should wait 1 hour before trying a failed refresh
                                                      1209600     ; Slave servers will serve requests for 2 weeks if it can't refresh
                                                      3600        ; TTL
                                                      )

        @                 IN              NS          ${name-server}.${internal-domain}.
        ${name-server}    IN              A           ${vars.networking.hostsAddr.MGC-DRW-DMC02.eth.ipv4}


        mgc-drw-bks01     IN              A           ${vars.networking.hostsAddr.MGC-DRW-BKS01.eth.ipv4}
        mgc-drw-bst01     IN              A           ${vars.networking.hostsAddr.MGC-DRW-BST01.eth.ipv4}
        mgc-drw-cld01     IN              A           ${vars.networking.hostsAddr.MGC-DRW-CLD01.eth.ipv4}
        mgc-drw-dgw01     IN              A           ${vars.networking.hostsAddr.MGC-DRW-DGW01.eth.ipv4}
        mgc-drw-dmc01     IN              A           ${vars.networking.hostsAddr.MGC-DRW-DMC01.eth.ipv4}
        mgc-drw-dmc02     IN              A           ${vars.networking.hostsAddr.MGC-DRW-DMC02.eth.ipv4}
        mgc-drw-fbr01     IN              A           ${vars.networking.hostsAddr.MGC-DRW-FBR01.eth.ipv4}
        mgc-drw-frw01     IN              A           ${vars.networking.defaultGateway}
        mgc-drw-git01     IN              A           ${vars.networking.hostsAddr.MGC-DRW-GIT01.eth.ipv4}
        mgc-drw-hvs01     IN              A           ${vars.networking.hostsAddr.MGC-DRW-HVS01.eth.ipv4}
        mgc-drw-hvs02     IN              A           ${vars.networking.hostsAddr.MGC-DRW-HVS02.eth.ipv4}
        mgc-drw-hvs03     IN              A           ${vars.networking.hostsAddr.MGC-DRW-HVS03.eth.ipv4}
        mgc-drw-mon01     IN              A           ${vars.networking.hostsAddr.MGC-DRW-MON01.eth.ipv4}
        mgc-drw-nbx01     IN              A           ${vars.networking.hostsAddr.MGC-DRW-NBX01.eth.ipv4}
        mgc-drw-nxc01     IN              A           ${vars.networking.hostsAddr.MGC-DRW-NXC01.eth.ipv4}
        mgc-drw-rst01     IN              A           ${vars.networking.hostsAddr.MGC-DRW-RST01.eth.ipv4}
        mgc-drw-rvp01     IN              A           ${vars.networking.hostsAddr.MGC-DRW-RVP01.eth.ipv4}
        mgc-drw-sem01     IN              A           ${vars.networking.hostsAddr.MGC-DRW-SEM01.eth.ipv4}
        mgc-drw-vlt01     IN              A           ${vars.networking.hostsAddr.MGC-DRW-VLT01.eth.ipv4}

        bookstack         IN              CNAME       mgc-drw-bks01
        grafana           IN              CNAME       mgc-drw-mon01
        netbox            IN              CNAME       mgc-drw-nbx01
        nextcloud         IN              CNAME       mgc-drw-nxc01
        semaphore         IN              CNAME       mgc-drw-sem01
        zabbix            IN              CNAME       mgc-drw-mon01
        vault             IN              CNAME       mgc-drw-vlt01
      '';
    };
  };
}
