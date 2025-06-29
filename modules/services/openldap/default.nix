{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.megacorp.services.openldap;

  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in {
  imports = [
    (mkIf cfg.enable (import ../../_shared/packages/godap.nix {
      inherit lib pkgs;
    }))
  ];

  options.megacorp.services.openldap = {
    enable = mkEnableOption "Enable domain controller";

    logo = mkEnableOption "Enable domain controller logo";

    domain-component = mkOption {
      type = types.str;
      default = "dc=megacorp,dc=local";
      description = ''
        The domain component in LDAP format.

        Example: dc=megacorp,dc=industries
      '';
    };

    extra-declarative-contents = mkOption {
      type = types.lines;
      default = "";
      description = ''
        LDIF formatted config that will be appended to already existing ./ou-structure.nix file.


        Declare users for example using something like this:

        ``
          dn: cn=John Smith,ou=IT,ou=Users,dc=megacorp,dc=local
          objectClass: person
          cn: John Smith
          sn: Smith
        ``;
      '';
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      389
      636
    ];

    services.openldap = {
      enable = true;

      /*
      enable plain connections only
      */
      urlList = [
        "ldap:///"
        "ldaps:///"
      ];

      settings = {
        attrs = {
          olcLogLevel = "conns config";
        };

        children = {
          "cn=schema".includes = [
            "${pkgs.openldap}/etc/schema/core.ldif"
            "${pkgs.openldap}/etc/schema/cosine.ldif"
            "${pkgs.openldap}/etc/schema/inetorgperson.ldif"
            "${pkgs.openldap}/etc/schema/nis.ldif"
          ];

          "olcDatabase={1}mdb".attrs = {
            objectClass = ["olcDatabaseConfig" "olcMdbConfig"];

            olcDatabase = "{1}mdb";
            olcDbDirectory = "/var/lib/openldap/data";

            olcSuffix = cfg.domain-component;

            olcRootDN = "cn=admin,${cfg.domain-component}";
            olcRootPW.path = "/run/secrets/olcRootPW";

            olcAccess = [
              /*
              custom access rules for userPassword attributes
              */
              ''                {0}to attrs=userPassword
                                  by self write
                                  by anonymous auth
                                  by * none''

              /*
              allow read on anything else
              */
              ''                {1}to *
                                  by * read''
            ];
          };
        };
      };

      declarativeContents = {
        "${cfg.domain-component}" =
          (import ./ou-structure.nix {
            inherit config;
          })
          + cfg.extra-declarative-contents;
      };
    };
  };
}
