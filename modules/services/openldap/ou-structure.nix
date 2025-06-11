{ config }: let
  cfg = config.megacorp.services.openldap;
  ou = "organizationalUnit";
in ''
  dn: ${cfg.domain-component}
  objectClass: domain
  dc: megacorp

  dn: ou=Users,${cfg.domain-component}
  objectClass: ${ou}
  ou: Users

  dn: ou=IT,ou=Users,${cfg.domain-component}
  objectClass: ${ou}
  ou: IT

  dn: ou=Finance,ou=Users,${cfg.domain-component}
  objectClass: ${ou}
  ou: Finance

  dn: ou=Reception,ou=Users,${cfg.domain-component}
  objectClass: ${ou}
  ou: Reception

  dn: ou=Managers,ou=Users,${cfg.domain-component}
  objectClass: ${ou}
  ou: Managers

''
