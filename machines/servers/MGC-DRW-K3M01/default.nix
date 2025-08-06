{
  nixpkgs,
  self,
  vars,
  ...
}:
nixpkgs.lib.nixosSystem {
  modules = [
    self.nixosModules.default
    {
      imports = [
        ../../_shared/qemu-hardware-config.nix
        (import ../../_shared/common-config.nix {
          inherit vars;
        })
      ];

      networking.hostName = "MGC-DRW-K3M01";

      system.stateVersion = "25.05";

      networking.firewall.allowedTCPPorts = [
        80
      ];

      services.k3s.manifests = {
        metallb = {
          enable = true;
          source = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/metallb/metallb/v0.15.2/config/manifests/metallb-native.yaml";
            hash = "sha256-obBMN2+znJMmX1Uf4jcWo65uCbeQ7bO/JX0/x4TDWhg=";
          };
        };

        metallb-pool = {
          enable = true;
          content = {
            apiVersion = "metallb.io/v1beta1";
            kind = "IPAddressPool";
            metadata = {
              name = "cheap";
              namespace = "metallb-system";
            };
            spec.addresses = [
              "192.168.1.64/28"
            ];
          };
        };

        nginx = {
          enable = true;
          content = [
            {
              apiVersion = "apps/v1";
              kind = "Deployment";
              metadata.name = "nginx-deployment";
              spec = {
                selector.matchLabels."app.kubernetes.io/name" = "nginx";
                template = {
                  metadata.labels."app.kubernetes.io/name" = "nginx";
                  spec.containers = [
                    {
                      name = "nginx";
                      image = "nginx:latest";
                      ports = [
                        {
                          containerPort = 80;
                        }
                      ];
                    }
                  ];
                };
              };
            }

            {
              apiVersion = "v1";
              kind = "Service";
              metadata.name = "nginx";
              spec = {
                type = "ClusterIP";
                selector."app.kubernetes.io/name" = "nginx";
                ports = [
                  {
                    protocol = "TCP";
                    port = 80;
                    targetPort = 80;
                  }
                ];
              };
            }

            {
              apiVersion = "networking.k8s.io/v1";
              kind = "Ingress";
              metadata = {
                name = "nginx-server";
                namespace = "default";
              };
              spec.rules = [
                {
                  host = "nginx.prod.megacorp.industries";
                  http.paths = [
                    {
                      path = "/";
                      pathType = "Prefix";
                      backend.service = {
                        name = "nginx";
                        port.number = 80;
                      };
                    }
                  ];
                }
              ];
            }
          ];
        };
      };

      megacorp = {
        config = {
          bootloader.enable = true;

          networking.static-ip = {
            enable = true;
            ipv4 = vars.networking.hostsAddr.MGC-DRW-K3M01.eth.ipv4;
            interface = vars.networking.hostsAddr.MGC-DRW-K3M01.eth.name;
            gateway = vars.networking.defaultGateway;
            nameservers = vars.networking.nameServers;
            lan-domain = vars.domains.internalDomain;
          };

          system.ad-domain = {
            enable = true;
            domain-name = vars.domains.internalDomain;
            netbios-name = "PROD";
            local-auth = {
              login = false;
              sudo = false;
              sshd = false;
              xrdp = false;
            };
          };
        };

        services.k3s = {
          enable = true;
          logo = true;
          cluster-init = true;
        };
      };
    }
  ];
}
