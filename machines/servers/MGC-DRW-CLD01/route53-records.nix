{vars}: {
  megacorp.cloud.aws.route53 = {
    enable = true;
    credential-path = "/home/benny/.aws/credentials";
    config-path = "/home/benny/.aws/credentials";
    records = {
      main = {
        zone_id = vars.awsZoneID;
        name = vars.primaryDomain;
        type = "A";
        records = [
          "${vars.primaryIP}"
        ];
      };

      mail-mx = {
        zone_id = vars.awsZoneID;
        name = vars.primaryDomain;
        type = "MX";
        records = [
          "10 mail.protonmail.ch."
          "20 mailsec.protonmail.ch."
        ];
      };

      mail-txt = {
        zone_id = vars.awsZoneID;
        name = vars.primaryDomain;
        type = "TXT";
        records = [
          "protonmail-verification=d0b28026b427ba737e5a6a79a6e3c833da85de5e"
        ];
      };

      mail-dmarc = {
        zone_id = vars.awsZoneID;
        name = "_dmarc.${vars.primaryDomain}";
        type = "TXT";
        records = [
          "v=DMARC1; p=quarantine"
        ];
      };

      mail-cname-1 = {
        zone_id = vars.awsZoneID;
        name = "protonmail._domainkey.${vars.primaryDomain}";
        type = "CNAME";
        records = [
          "protonmail.domainkey.dkgcgqd47lmlbegrwsaoxwusl6mweqym7566o2nkf4gwhustgzoyq.domains.proton.ch."
        ];
      };

      mail-cname-2 = {
        zone_id = vars.awsZoneID;
        name = "protonmail2._domainkey.${vars.primaryDomain}";
        type = "CNAME";
        records = [
          "protonmail2.domainkey.dkgcgqd47lmlbegrwsaoxwusl6mweqym7566o2nkf4gwhustgzoyq.domains.proton.ch."
        ];
      };

      mail-cname-3 = {
        zone_id = vars.awsZoneID;
        name = "protonmail3._domainkey.${vars.primaryDomain}";
        type = "CNAME";
        records = [
          "protonmail3.domainkey.dkgcgqd47lmlbegrwsaoxwusl6mweqym7566o2nkf4gwhustgzoyq.domains.proton.ch."
        ];
      };

      cv = {
        zone_id = vars.awsZoneID;
        name = "cv.${vars.primaryDomain}";
        type = "CNAME";
        records = [
          "${vars.primaryDomain}"
        ];
      };

      guacamole = {
        zone_id = vars.awsZoneID;
        name = vars.guacamoleFQDN;
        type = "CNAME";
        records = [
          "${vars.primaryDomain}"
        ];
      };

      file-browser = {
        zone_id = vars.awsZoneID;
        name = vars.file-browserFQDN;
        type = "CNAME";
        records = [
          "${vars.primaryDomain}"
        ];
      };
    };
  };
}
