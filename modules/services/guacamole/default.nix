{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.megacorp.services.guacamole;

  app = "guacamole";
  guacVer = config.services.guacamole-client.package.version;

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

  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;

  use-acme-cert =
    if cfg.tls.cert-key == null || cfg.tls.cert-file == null
    then true
    else false;
in {
  imports = [
    (mkIf cfg.tls.enable (import ../../_shared/nginx/tls-config.nix {
      inherit cfg lib use-acme-cert;
    }))
    (import ./extension-postgres.nix {
      inherit cfg config lib pkgs;
    })
    (import ./extension-ldap.nix {
      inherit cfg config lib pkgs;
    })
  ];

  options.megacorp.services.guacamole = {
    enable = mkEnableOption "Enable Guacamole";

    logo = mkEnableOption "Whether to show Guacamole logo on shell startup";

    mfa = mkEnableOption "Whether to enable MFA extension";

    port = mkOption {
      type = types.int;
      default = 8080;
      description = "The port number for guacamole to listen on";
    };

    fqdn = mkOption {
      type = types.str;
      default = "localhost";
      description = ''
        The fqdn of your guacamole instance.
        NOTE: Don't include "https://" (this is prepended to the value)
      '';
    };

    tls = import ../../_shared/nginx/tls-options.nix {
      inherit lib;
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      80
    ];

    environment = {
      # Applying overlay ../../../overlays/freerdp.nix
      systemPackages = [
        pkgs.freerdp
      ];

      etc."guacamole/extensions/guacamole-auth-totp-${guacVer}.jar" = {
        enable =
          if cfg.mfa
          then true
          else false;
        source = "${totpExtension}/guacamole-auth-totp-${guacVer}.jar";
      };
    };

    systemd.services.tomcat = {
      requires = ["postgresql.service"];
      after = ["postgresql.service"];
      restartIfChanged = false;
    };

    services = {
      nginx = {
        enable = true;
        virtualHosts."${cfg.fqdn}".locations = {
          "/" = {
            return = "301 http://${cfg.fqdn}/guacamole";
          };
          "/guacamole/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.port}";
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

      guacamole-server = {
        enable = true;
        host = "127.0.0.1";
        package = pkgs.guacamole-server; # Applying overlay ../../../overlays/guacamole-server.nix
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
