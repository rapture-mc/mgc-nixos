{vars}: let
  zone-id = "\${ aws_route53_zone.megacorp-industries.zone_id }";
in {
  megacorp.cloud.aws.route53 = {
    enable = true;
    credential-path = "/home/ben.harris/.aws/credentials";
    config-path = "/home/ben.harris/.aws/credentials";
    terraform.state-dir = "/var/lib/terranix-state/aws/route53";
    zones = {
      megacorp-industries = {
        name = "${vars.domains.primaryDomain}.";
      };
    };
    records = {
      main = {
        zone_id = zone-id;
        name = vars.domains.primaryDomain;
        type = "A";
        records = [
          "${vars.networking.megacorpPrimaryPublicIP}"
        ];
      };

      mail = {
        zone_id = zone-id;
        name = "mail.${vars.domains.primaryDomain}";
        type = "A";
        records = [
          "${vars.networking.awsPrimaryPublicIP}"
        ];
      };

      mail-mx = {
        zone_id = zone-id;
        name = vars.domains.primaryDomain;
        type = "MX";
        records = [
          "10 mail.megacorp.industries."
          # "10 mail.protonmail.ch."
          # "20 mailsec.protonmail.ch."
          "32767 ms57820714.msv1.invalid"
        ];
      };

      mail-txt = {
        zone_id = zone-id;
        name = vars.domains.primaryDomain;
        type = "TXT";
        records = [
          # "protonmail-verification=d0b28026b427ba737e5a6a79a6e3c833da85de5e"
          "v=spf1 a:mail.megacorp.industries -all"
          "MS=ms57820714"
        ];
      };

      mail-dmarc = {
        zone_id = zone-id;
        name = "_dmarc.${vars.domains.primaryDomain}";
        type = "TXT";
        records = [
          "v=DMARC1; p=none"
        ];
      };

      # mail-dkim = {
      #   zone_id = zone-id;
      #   name = "mail._domainkey.${vars.domains.primaryDomain}";
      #   type = "TXT";
      #   records = [
      #     "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAt9npCATJoV5od4WRx2ZFEG5M5vScACPbZUULQUcwafJV/HbS4YnSuCnRXeIQELfYpB7AhbIg+aL6DBvWI+vrhMYQnf4RjhrTR8lfzrePBoNLIlzRdnTSrN2cJjGjpsVYsppXhgeX6rY1fJFYD+OkkoRlS8gnETWjI97+fq4DKHfj23bQgG6k5RtW3T+XRcbTFCeWo7iKjrFj1wrFs"
      #   ];
      # };
      #
      # mail-cname-1 = {
      #   zone_id = zone-id;
      #   name = "protonmail._domainkey.${vars.domains.primaryDomain}";
      #   type = "CNAME";
      #   records = [
      #     "protonmail.domainkey.dkgcgqd47lmlbegrwsaoxwusl6mweqym7566o2nkf4gwhustgzoyq.domains.proton.ch."
      #   ];
      # };
      #
      # mail-cname-2 = {
      #   zone_id = zone-id;
      #   name = "protonmail2._domainkey.${vars.domains.primaryDomain}";
      #   type = "CNAME";
      #   records = [
      #     "protonmail2.domainkey.dkgcgqd47lmlbegrwsaoxwusl6mweqym7566o2nkf4gwhustgzoyq.domains.proton.ch."
      #   ];
      # };
      #
      # mail-cname-3 = {
      #   zone_id = zone-id;
      #   name = "protonmail3._domainkey.${vars.domains.primaryDomain}";
      #   type = "CNAME";
      #   records = [
      #     "protonmail3.domainkey.dkgcgqd47lmlbegrwsaoxwusl6mweqym7566o2nkf4gwhustgzoyq.domains.proton.ch."
      #   ];
      # };

      cv = {
        zone_id = zone-id;
        name = "cv.${vars.domains.primaryDomain}";
        type = "CNAME";
        records = [
          "${vars.domains.primaryDomain}"
        ];
      };

      guacamole = {
        zone_id = zone-id;
        name = vars.domains.guacamoleFQDN;
        type = "CNAME";
        records = [
          "${vars.domains.primaryDomain}"
        ];
      };

      file-browser = {
        zone_id = zone-id;
        name = vars.domains.file-browserFQDN;
        type = "CNAME";
        records = [
          "${vars.domains.primaryDomain}"
        ];
      };

      semaphore = {
        zone_id = zone-id;
        name = vars.domains.semaphoreFQDN;
        type = "CNAME";
        records = [
          "${vars.domains.primaryDomain}"
        ];
      };
    };
  };
}
