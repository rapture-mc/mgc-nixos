{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.megacorp.services.file-browser;

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

  options.megacorp.services.file-browser = {
    enable = mkEnableOption "Enable File Browser";

    fqdn = mkOption {
      type = types.str;
      default = "localhost";
      description = ''
        The fqdn of your File Browser instance.
        NOTE: Don't include "https://" (this is prepended to the value)
      '';
    };

    port = mkOption {
      type = types.int;
      default = 8080;
      description = "The port number for file-browser to listen on";
    };

    data-path = mkOption {
      type = types.str;
      default = "/data/file-browser";
      description = "The full path of the file browser data";
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
        };
      };
    };

    systemd.services."file-browser-setup" = {
      wantedBy = ["file-browser.service"];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      script = ''
        if [ ! -d "${cfg.data-path}" ]; then
          echo "Directory ${cfg.data-path} doesn't exist... Creating..."
          mkdir -p ${cfg.data-path}
          chown 1000:1000 ${cfg.data-path}
        else
          echo "Directory ${cfg.data-path} already exists... Skipping..."
        fi
      '';
    };

    virtualisation = {
      docker.enable = true;

      arion = {
        backend = "docker";
        projects.file-browser = {
          serviceName = "file-browser";
          settings = {
            config = {
              project.name = "file-browser";
              docker-compose.volumes = {
                file-browser-config = {};
              };

              services = {
                filebrowser = {
                  service = {
                    image = "hurlenko/filebrowser";
                    user = "1000:1000";
                    restart = "always";
                    ports = ["8080:8080"];
                    volumes = [
                      "${cfg.data-path}:/data"
                      "file-browser-config:/config"
                    ];
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
