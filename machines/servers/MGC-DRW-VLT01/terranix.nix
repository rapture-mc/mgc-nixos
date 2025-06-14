{
  system,
  terranix,
  pkgs,
  vars,
  ...
}: let
  vault-root-token-path = "/run/secrets/vault-root-token";

  terraform-config = terranix.lib.terranixConfiguration {
    inherit system;
    modules = [
      {
        terraform.required_providers.vault.source = "hashicorp/vault";

        provider.vault.address = "http://${vars.networking.hostsAddr.MGC-DRW-VLT01.eth.ipv4}:8200";

        resource = {
          vault_policy = import ./vault/policies.nix;
          vault_mount = import ./vault/mounts.nix;

          # Root CA backend config
          vault_pki_secret_backend_root_cert = (import ./vault/root-cert-2025.nix {
            inherit vars;
          });
          vault_pki_secret_backend_issuer = import ./vault/backend-issuer.nix;
          vault_pki_secret_backend_config_urls = (import ./vault/backend-config-urls.nix {
            inherit vars;
          });

          # Intermediate CA backend config
          vault_pki_secret_backend_intermediate_cert_request = (import ./vault/backend-intermediate-cert-request.nix {
            inherit vars;
          });
          vault_pki_secret_backend_root_sign_intermediate = import ./vault/backend-root-sign-intermediate.nix;
          vault_pki_secret_backend_intermediate_set_signed = import ./vault/backend-intermediate-set-signed.nix;

          # PKI Roles
          vault_pki_secret_backend_role = (import ./vault/backend-role.nix {
            inherit vars;
          });

          local_file = {
            root-cert-2025 = {
              content = "\${ vault_pki_secret_backend_root_cert.root-cert-2025.certificate }";
              filename = "/home/${vars.adminUser}/vault/root-cert-2025.crt";
            };

            intermediate-cert = {
              content = "\${ vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate }";
              filename = "/home/${vars.adminUser}/vault/intermediate-cert.crt";
            };
          };
        };
      }
    ];
  };
in {
  systemd.services.vault-config-provisioner = {
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    path = [
      pkgs.git
      pkgs.getent
      pkgs.coreutils
    ];
    serviceConfig.ExecStart = toString (pkgs.writers.writeBash "generate-vault-config" ''
      export VAULT_TOKEN=$(cat ${vault-root-token-path})
      if [[ -e config.tf.json ]]; then
        rm -f config.tf.json;
      fi

      cp ${terraform-config} config.tf.json \
        && ${pkgs.opentofu}/bin/tofu init \
        && ${pkgs.opentofu}/bin/tofu apply -auto-approve
    '');
  };
}
