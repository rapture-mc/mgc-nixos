{
  pkgs,
  lib,
  config,
  system,
  terranix,
  ...
}: let
  cfg = config.megacorp.services.vault;

  inherit
    (lib)
    mkOption
    mkEnableOption
    types
    mkIf
    ;

  terraform-config = terranix.lib.terranixConfiguration {
    inherit system;
    modules = [
      {
        terraform.required_providers.vault.source = "hashicorp/vault";

        provider.vault.address = "http://${cfg.address}";

        resource = {
          # Mounts
          vault_policy = import ./policies.nix;
          vault_mount = import ./mounts.nix;

          # Root CA backend config
          vault_pki_secret_backend_root_cert = (import ./root-cert.nix {
            inherit config;
          });
          vault_pki_secret_backend_issuer = import ./root-issuer.nix;
          vault_pki_secret_backend_config_urls = (import ./config-urls.nix {
            inherit config;
          });

          # Intermediate CA backend config
          vault_pki_secret_backend_intermediate_cert_request = (import ./csr-request.nix {
            inherit config;
          });
          vault_pki_secret_backend_root_sign_intermediate = (import ./root-sign-intermediate.nix {
            inherit config;
          });
          vault_pki_secret_backend_intermediate_set_signed = import ./intermediate-set-signed.nix;

          # PKI Roles
          vault_pki_secret_backend_role = (import ./role.nix {
            inherit config;
          });

          local_file = {
            root-cert = {
              content = "\${ vault_pki_secret_backend_root_cert.root-cert.certificate }";
              filename = "/var/lib/vault/root-cert.crt";
            };

            intermediate-cert = {
              content = "\${ vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate }";
              filename = "/var/lib/vault/intermediate-cert.crt";
            };
          };
        };
      }
    ];
  };
in {
  options.megacorp.services.vault.pki = {
    enable = mkEnableOption "Whether to enable Hashicorp PKI engine";

    common-name = mkOption {
      type = types.str;
      default = "Megacorp Industries";
      description = "The common name for the root certificate";
    };

    allowed-domains = mkOption {
      type = types.str;
      default = "megacorp.industries";
      description = "The domains that this CA is allowed to issue certificates for";
    };
  };

  config = mkIf cfg.pki.enable {
    systemd.services.vault-config-provisioner = {
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      path = [
        pkgs.git
        pkgs.getent
        pkgs.coreutils
      ];
      serviceConfig.ExecStart = toString (pkgs.writers.writeBash "generate-vault-config" ''
        export VAULT_TOKEN=$(cat ${cfg.vault-token})

        if [[ -e config.tf.json ]]; then
          rm -f config.tf.json;
        fi

        cp ${terraform-config} config.tf.json \
          && ${pkgs.opentofu}/bin/tofu init \
          && ${pkgs.opentofu}/bin/tofu apply -auto-approve
      '');
    };

  };
}
