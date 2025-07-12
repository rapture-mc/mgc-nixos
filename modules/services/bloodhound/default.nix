{
  lib,
  config,
  ...
}: let
  cfg = config.megacorp.services.bloodhound;

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

  options.megacorp.services.bloodhound = {
    enable = mkEnableOption "Enable Bloodhound CE";

    fqdn = mkOption {
      type = types.str;
      default = "localhost";
      description = ''
        The fqdn of your bloodhound instance.
        NOTE: Don't include "https://" (this is prepended to the value)
      '';
    };

    port = mkOption {
      type = types.int;
      default = 8080;
      description = "The port number for bloodhound to listen on";
    };

    tls = import ../../_shared/nginx/tls-options.nix {
      inherit lib;
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      80
    ];

    services = {
      nginx = {
        enable = true;
        recommendedProxySettings = true;
        virtualHosts."${cfg.fqdn}" = {
          locations = {
            "/" = {
              proxyPass = "http://127.0.0.1:${toString cfg.port}";
            };
          };
        };
      };
    };

    virtualisation = {
      arion = {
        backend = "podman-socket";
        projects.bloodhound = {
          serviceName = "bloodhound";
          settings = {
            config = {
              project.name = "bloodhound";
              docker-compose.volumes = {
                bloodhound-postgres = {};
                bloodhound-neo4j = {};
              };

              services = {
                postgres.service = {
                  image = "docker.io/library/postgres:16";
                  restart = "always";
                  volumes = ["bloodhound-postgres:/var/lib/postgresql/data"];
                  environment = {
                    PGUSER = "bloodhound";
                    POSTGRES_DB = "bloodhound";
                    POSTGRES_USER = "bloodhound";
                  };
                  env_file = [
                    "/run/secrets/postgres-password"
                  ];
                  healthcheck = {
                    test = [
                      "CMD-SHELL"
                      "pg_isready -U bloodhound -d bloodhound -h 127.0.0.1 -p 5432"
                    ];
                    interval = "10s";
                    timeout = "5s";
                    retries = 5;
                    start_period = "30s";
                  };
                };

                neo4j.service = {
                  image = "docker.io/library/neo4j:4.4.42";
                  environment = {
                    NEO4J_dbms_allow__upgrade = "true";
                  };
                  env_file = [
                    "/run/secrets/neo4j-auth"
                  ];
                  ports = [
                    "127.0.0.1:7687:7687"
                    "127.0.0.1:7474:7474"
                  ];
                  volumes = [
                    "bloodhound-neo4j:/data"
                  ];
                  healthcheck = {
                    test = [
                      "CMD-SHELL"
                      "wget -O /dev/null -q http://localhost:7474 || exit 1"
                    ];
                    interval = "10s";
                    timeout = "5s";
                    retries = 5;
                    start_period = "30s";
                  };
                };

                bloodhound = {
                  service = {
                    image = "docker.io/specterops/bloodhound:latest";
                    restart = "always";
                    ports = ["127.0.0.1:8080:8080"];
                    environment = {
                      bhe_disable_cypher_complexity_limit = "false";
                      bhe_enable_cypher_mutations = "false";
                      bhe_graph_query_memory_limit = 2;
                      bhe_database_username = "bloodhound";
                      bhe_database_database = "bloodhound";
                      bhe_database_addr = "postgres";
                      bhe_graph_driver = "neo4j";
                    };
                    env_file = [
                      "/run/secrets/bhe-neo4j-connection"
                      "/run/secrets/bhe-database-secret"
                    ];
                    depends_on = {
                      postgres.condition = "service_healthy";
                      neo4j.condition = "service_healthy";
                    };
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
