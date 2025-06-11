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

  totpExtension = pkgs.stdenv.mkDerivation {
    name = "guacamole-auth-totp-${guacVer}";
    src = pkgs.fetchurl {
      url = "https://apache.org/dyn/closer.lua/guacamole/${guacVer}/binary/guacamole-auth-totp-${guacVer}.tar.gz?action=download";
      sha256 = "sha256-N/L52Jto28tE5TSeMEdKONeSJNvrCmfwPs/nh6X+r0I=";
    };
    phases = "unpackPhase installPhase";
    unpackPhase = ''
      tar -xzf $src
    '';
    installPhase = ''
      mkdir -p $out
      cp guacamole-auth-totp-${guacVer}/guacamole-auth-totp-${guacVer}.jar $out
    '';
  };

  psql = "${pkgs.postgresql}/bin/psql";
  cat = "${pkgs.coreutils-full}/bin/cat";

  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in {
  options.megacorp.services.guacamole = {
    enable = mkEnableOption "Enable Guacamole";

    logo = mkEnableOption "Whether to show Guacamole logo on shell startup";

    mfa = mkEnableOption "Whether to enable MFA extension";

    reverse-proxied = mkEnableOption "Whether Guacamole is served behind a reverse proxy";

    tls-email = mkOption {
      type = types.str;
      default = "someone@somedomain.com";
      description = ''
        The email to use for automatic SSL certificates
        This email will also get SSL certificate renewal email notifications
      '';
    };

    fqdn = mkOption {
      type = types.str;
      default = "localhost";
      description = ''
        The fqdn of your guacamole instance.
        NOTE: Don't include "https://" (this is prepended to the value)
      '';
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts =
      [
        8080
      ]
      ++ (
        if !cfg.reverse-proxied
        then [80 443]
        else []
      );

    security.acme = mkIf (!cfg.reverse-proxied) {
      acceptTerms = true;
      defaults.email = "${cfg.tls-email}";
    };

    environment.etc = {
      "guacamole/lib/postgresql-${pgsqlVer}.jar".source = pgsqlDriverSrc;

      "guacamole/extensions/guacamole-auth-jdbc-postgresql-${guacVer}.jar".source = "${pgsqlExtension}/guacamole-auth-jdbc-postgresql-${guacVer}.jar";

      "guacamole/extensions/guacamole-auth-totp-${guacVer}.jar" = {
        enable =
          if cfg.mfa
          then true
          else false;
        source = "${totpExtension}/guacamole-auth-totp-${guacVer}.jar";
      };
    };

    systemd.services = {
      tomcat = {
        requires = ["postgresql.service"];
        after = ["postgresql.service"];
      };

      guacamole-pgsql-schema-import = {
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
    };

    services = {
      nginx = mkIf (!cfg.reverse-proxied) {
        enable = true;
        virtualHosts."${cfg.fqdn}" = {
          forceSSL = true;
          enableACME = true;
          locations = {
            "/" = {
              return = "301 https://${cfg.fqdn}/guacamole";
            };
            "/guacamole/" = {
              proxyPass = "http://127.0.0.1:8080";
              extraConfig = ''
                proxy_http_version 1.1;
                proxy_buffering off;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection $http_connection;
                access_log off;
              '';
            };
          };
        };
      };

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

      guacamole-server = {
        enable = true;
        host = "127.0.0.1";
      };

      guacamole-client = {
        enable = true;
        enableWebserver = true;
        package = pkgs.guacamole-client;
        settings = {
          guacd-port = 4822;
          postgresql-hostname = "127.0.0.1";
          postgresql-database = app;
          postgresql-username = app;
          postgresql-password = "";
        };
      };
    };
  };
}
