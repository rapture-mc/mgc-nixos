{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.megacorp.services.guacamole.ldap;

  guacVer = config.services.guacamole-client.package.version;

  ldapExtension = pkgs.stdenv.mkDerivation {
    name = "guacamole-auth-ldap-${guacVer}";
    src = pkgs.fetchurl {
      url = "https://apache.org/dyn/closer.lua/guacamole/${guacVer}/binary/guacamole-auth-ldap-${guacVer}.tar.gz?action=download";
      sha256 = "sha256-AdPNdNpd6dqcxzp4irKTjdRPXL5CrZDuu0vuB/JG36M=";
    };
    phases = "unpackPhase installPhase";
    unpackPhase = ''
      tar -xzf $src
    '';
    installPhase = ''
      mkdir -p $out
      cp guacamole-auth-ldap-${guacVer}/guacamole-auth-ldap-${guacVer}.jar $out
    '';
  };

  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;

  # Need to patch jdk8 package with own trusted root certificates
  patched-jdk = pkgs.jdk8.override {
    cacert = pkgs.runCommand "mycacert" {} ''
      mkdir -p $out/etc/ssl/certs
      cat ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt > $out/etc/ssl/certs/ca-bundle.crt
      echo "${cfg.tls.root-cert}" >> $out/etc/ssl/certs/ca-bundle.crt
    '';
  };
in {
  options.megacorp.services.guacamole.ldap = {
    enable = mkEnableOption "Enable Guacamole";

    port = mkOption {
      type = types.int;
      default = 6360;
      description = "The port number of the LDAP server to connect to.";
    };

    server = mkOption {
      type = types.str;
      default = "";
      description = "The LDAP server hostname or fqdn";
    };

    user-base-dn = mkOption {
      type = types.str;
      default = "";
      description = ''
        The base DN to use to search for users.

        E.g "ou=people,dc=example,dc=com"
      '';
    };

    search-bind-dn = mkOption {
      type = types.str;
      default = "";
      description = ''
        The DN of the user to authenticate to the LDAP server with.

        E.g "uid=admin,ou=people,dc=example,dc=com"
      '';
    };

    user-search-filter = mkOption {
      type = types.str;
      default = "";
      description = ''
        The LDAP search filter to decide who can login to the application.

        E.g "(memberof=cn=guacamole,ou=groups,dc=example,dc=com)"
      '';
    };

    admin-ldap-password-file = mkOption {
      type = types.path;
      default = "";
      description = "The absolute path to a password file containing the LDAP admin password";
    };

    tls = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to use TLS to connect to the LDAP server.

          This should be true as communicating over unencrypted LDAP is insecure and not advised.
        '';
      };

      root-cert = mkOption {
        type = types.str;
        default = "";
        description = ''
          The root CA certificate (and any intermediaries) to trust so guacamole can establish a TLS connection with the LDAP server.

          Usually setting security.pki.certificates would suffice however Java (tomcat) is stubborn and uses it's own cert store therefore we must explicitly set it here.

          NOTE: This also results in a long build time since Nix has to recompile the JDK package with the new cert.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    # Making tomcat webserver use our patched version of JDK
    services.tomcat.jdk = patched-jdk;

    environment.etc."guacamole/extensions/guacamole-auth-ldap-${guacVer}.jar".source = "${ldapExtension}/guacamole-auth-ldap-${guacVer}.jar";

    systemd.services.inject-ldap-password = {
      wantedBy = [
        "multi-user.target"
      ];

      serviceConfig = {
        Type = "oneshot";
        User = "root";
        Group = "root";
        ExecStartPost = "${pkgs.systemdUkify}/bin/systemctl restart tomcat.service";
      };

      script = ''
        if [[ -r ${cfg.admin-ldap-password-file} ]]; then
          umask 0077
          temp_conf="$(mktemp)"
          cp ${config.environment.etc."guacamole/guacamole.properties".source} $temp_conf
          printf 'ldap-search-bind-password = %s\n' "$(cat ${cfg.admin-ldap-password-file})" >> $temp_conf
          mv -fT "$temp_conf" /etc/guacamole/guacamole.properties
          chown root:tomcat /etc/guacamole/guacamole.properties
          chmod 750 /etc/guacamole/guacamole.properties
        fi
      '';
    };

    # Ensure no race conditions exist between insert-ldap-password and existing guacamole-client module
    environment.etc."guacamole/guacamole.properties".enable = false;

    services.guacamole-client.settings = {
      ldap-hostname = cfg.server;
      ldap-port = cfg.port;
      ldap-encryption-method =
        if cfg.tls.enable
        then "ssl"
        else "none";
      ldap-user-base-dn = cfg.user-base-dn;
      ldap-search-bind-dn = cfg.search-bind-dn;
      ldap-user-search-filter = cfg.user-search-filter;
      username-attribute = "sAMAccountName";
    };
  };
}
