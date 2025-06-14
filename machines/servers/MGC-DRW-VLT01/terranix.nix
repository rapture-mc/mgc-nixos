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

        resource.vault_policy.example = {
          name = "example-policy";

          policy = ''
            path "secret/my_app" {
              capabilities = ["update"]
            }
          '';
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
