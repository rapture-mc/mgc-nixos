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


        netbox            IN              A           ${vars.networking.hostsAddr.MGC-DRW-NBX01.eth.ipv4}
      '';
    };
  };
}
