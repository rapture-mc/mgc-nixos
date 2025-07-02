{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.megacorp.services.guacamole;

  app = "guacamole";
  guacVer = config.services.guacamole-client.package.version;
  pgsqlVer = "42.7.1";

  pgsqlDriverSrc = pkgs.fetchurl {
    url = "https://jdbc.postgresql.org/download/postgresql-${pgsqlVer}.jar";
    sha256 = "sha256-SbupwyANT2Suc5A9Vs4b0Jx0UX3+May0R0VQa0/O3lM=";
  };

  pgsqlExtension = pkgs.stdenv.mkDerivation {
    name = "guacamole-auth-jdbc-postgresql-${guacVer}";
    src = pkgs.fetchurl {
      url = "https://dlcdn.apache.org/guacamole/${guacVer}/binary/guacamole-auth-jdbc-${guacVer}.tar.gz";
      sha256 = "sha256-gMygoCB2urrQ3Hx2tg2qiW89m/EL6CcI9CX9Qs5BE5M=";
    };
    phases = "unpackPhase installPhase";
    unpackPhase = ''
      tar -xzf $src
    '';
    installPhase = ''
      mkdir -p $out
      cp -r guacamole-auth-jdbc-${guacVer}/postgresql/* $out
    '';
  };

  psql = "${pkgs.postgresql}/bin/psql";
  cat = "${pkgs.coreutils-full}/bin/cat";

  inherit
    (lib)
    mkIf
    ;
in {
  config = mkIf cfg.enable {
    environment.etc = {
      "guacamole/lib/postgresql-${pgsqlVer}.jar".source = pgsqlDriverSrc;
      "guacamole/extensions/guacamole-auth-jdbc-postgresql-${guacVer}.jar".source = "${pgsqlExtension}/guacamole-auth-jdbc-postgresql-${guacVer}.jar";
    };

    systemd.services.guacamole-pgsql-schema-import = {
      enable = true;
      requires = ["postgresql.service"];
      after = ["postgresql.service"];
      wantedBy = ["tomcat.service" "multi-user.target"];
      script = ''
        echo "[guacamole-bootstrapper] Info: checking if database '${app}' exists but is empty..."

        output=$(${psql} -U ${app} -c "\dt" 2>&1)

        if [[ $output == "Did not find any relations." ]]; then
          echo "[guacamole-bootstrapper] Info: installing guacamole postgres database schema..."
          ${cat} ${pgsqlExtension}/schema/*.sql | ${psql} -U ${app} -d ${app} -f -
        fi
      '';
    };

    services = {
      postgresql = {
        enable = true;
        authentication = pkgs.lib.mkOverride 10 ''
          #type database  DBuser  auth-method
          local all       all     trust
          #type database DBuser origin-address auth-method
          host  all      all    127.0.0.1/32   trust
        '';
        ensureDatabases = [
          app
        ];
        ensureUsers = [
          {
            name = app;
            ensureDBOwnership = true;
          }
        ];
      };
    };
  };
}
