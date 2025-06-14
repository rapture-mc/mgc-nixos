{
  system,
  terranix,
  pkgs,
  ...
}: let
  terraform-config = terranix.lib.terranixConfiguration {
    inherit system;
    modules = [
      {
        terraform.required_providers.vault.source = "hashicorp/vault";

        provider.vault = {
          address = "http://127.0.0.1:8200";
        };

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
    path = [pkgs.git];
    serviceConfig.ExecStart = toString (pkgs.writers.writeBash "generate-vault-config" ''
      if [[ -e config.tf.json ]]; then
        rm -f config.tf.json;
      fi

      cp ${terraform-config} config.tf.json \
        && ${pkgs.opentofu}/bin/tofu init \
        && ${pkgs.opentofu}/bin/tofu apply -auto-approve
    '');
  };
}
