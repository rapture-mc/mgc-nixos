{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.megacorp.services.semaphore;

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
  ];

  options.megacorp.services.semaphore = {
    enable = mkEnableOption "Enable Semaphore";

    fqdn = mkOption {
      type = types.str;
      default = "localhost";
      description = ''
        The fqdn of your Semaphore instance.
        NOTE: Don't include "https://" (this is prepended to the value)
      '';
    };

    admin-email = mkOption {
      type = types.str;
      default = "someone@somedomain.com";
      description = "The email of the admin user";
    };

    port = mkOption {
      type = types.int;
      default = 3000;
      description = "The port number for file-browser to listen on";
    };

    kerberos = {
      enable = mkEnableOption "Enable Kerberos authentication";

      kdc = mkOption {
        type = types.str;
        default = "";
        description = "The hostname of the KDC server (hostname of the domain controller)";
      };

      domain = mkOption {
        type = types.str;
        default = "";
        description = "The domain name (e.g. contoso.com) of the domain controller";
      };
    };

    tls = import ../../_shared/nginx/tls-options.nix {
      inherit lib;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.lazydocker];

    # Note: Docker doesn't respect the NixOS firewall and will open port 8080 since we declared that in the compose file
    networking.firewall.allowedTCPPorts = [
      80
    ];

    services.nginx = {
      enable = true;
      virtualHosts."${cfg.fqdn}" = {
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.port}";
          };
          "/api/ws" = {
            proxyPass = "http://127.0.0.1:${toString cfg.port}/api/ws";
            proxyWebsockets = true;
          };
        };
      };
    };

    # See https://github.com/NixOS/nixpkgs/issues/95017
    security.pam.krb5.enable = false;

    security.krb5 = mkIf cfg.kerberos.enable {
      enable = true;
      settings = {
        logging = {
          default = "FILE:/var/log/krb5libs.log";
          kdc = "FILE:/var/log/krb5kdc.log";
          admin_server = "FILE:/var/log/kadmin.log";
        };

        libdefaults = {
          dns_lookup_realm = false;
          ticket_lifetime = "24h";
          renew_lifetime = "7d";
          forwardeable = true;
          rdns = false;
          default_realm = "${pkgs.lib.toUpper cfg.kerberos.domain}";
        };

        realms = {
          "${pkgs.lib.toUpper cfg.kerberos.domain}" = {
            admin_server = "${cfg.kerberos.kdc}.${cfg.kerberos.domain}";
            kdc = [
              "${cfg.kerberos.kdc}.${cfg.kerberos.domain}"
            ];
          };
        };
      };
    };

    virtualisation = {
      docker.enable = true;

      arion = {
        backend = "docker";
        projects.semaphore = {
          serviceName = "semaphore";
          settings = {
            config = {
              project.name = "semaphore";
              docker-compose.volumes = {
                semaphore-postgres = {};
              };

              services = {
                postgres = {
                  service = {
                    image = "postgres";
                    restart = "always";
                    volumes = ["semaphore-postgres:/var/lib/postgresql/data"];
                    environment = {
                      POSTGRES_DB = "semaphore";
                      POSTGRES_USER = "semaphore";
                    };
                    env_file = [
                      "/run/secrets/postgres-password"
                    ];
                  };
                };

                semaphore = {
                  service = {
                    build.context = "${./docker}";
                    restart = "always";
                    ports = ["${toString cfg.port}:3000"];
                    volumes = mkIf cfg.kerberos.enable [
                      "/etc/krb5.conf:/etc/krb5.conf"
                    ];
                    environment = {
                      WEB_HOST = "https://${cfg.fqdn}";
                      SEMAPHORE_DB_USER = "semaphore";
                      SEMAPHORE_DB_HOST = "postgres";
                      SEMAPHORE_DB_PORT = "5432";
                      SEMAPHORE_DB_DIALECT = "postgres";
                      SEMAPHORE_DB = "semaphore";
                      SEMAPHORE_PLAYBOOK_PATH = "/tmp/semaphore/";
                      SEMAPHORE_ADMIN_NAME = "admin";
                      SEMAPHORE_ADMIN_PASSWORD = "changeme";
                      SEMAPHORE_ADMIN_EMAIL = "${cfg.admin-email}";
                      SEMAPHORE_ADMIN = "admin";
                      USE_REMOTE_RUNNER = "true";
                    };
                    env_file = [
                      "/run/secrets/semaphore-db-pass"
                      "/run/secrets/semaphore-access-key-encryption"
                    ];
                    depends_on = ["postgres"];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
