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

  # Define ewxtra attributes to append to cfg.pki.certs.<name>
  # We define these here instead of the cfg.pki.certs.<name> option definition because they never change
  extra-cert-attributes = {
    issuer_ref = "\${ vault_pki_secret_backend_issuer.root-issuer.issuer_ref }";
    backend = "\${ vault_pki_secret_backend_role.intermediate-role.backend }";
    name = "\${ vault_pki_secret_backend_role.intermediate-role.name }";
    revoke = true;
  };

  # Append above attributes to the cfg.pki.certs.<name> definitions
  modified-cert-attributes =
    lib.mapAttrs (
      name: value:
        if lib.isAttrs value
        then value // extra-cert-attributes
        else value
    )
    cfg.pki.certs;

  # This function now needs to return a LIST of attribute sets,
  # each suitable for listToAttrs.
  # So, it generates a list like:
  # [
  #   { name = "mgc-drw-vlt01-key"; value = { filename = "..."; content = "..."; }; }
  #   { name = "mgc-drw-vlt01-cert"; value = { filename = "..."; content = "..."; }; }
  # ]
  generate-file-entries = name: [
    {
      name = "${name}-key";
      value = {
        filename = "${cfg.pki.cert-output-dir}/${name}.pem";
        content = "\${ vault_pki_secret_backend_cert.${name}.private_key }";
      };
    }

    {
      name = "${name}-cert";
      value = {
        filename = "${cfg.pki.cert-output-dir}/${name}.crt";
        content = "\${ vault_pki_secret_backend_cert.${name}.certificate }";
      };
    }
  ];

  # 1. Map 'modified-cert-attributes' to a list of lists of file entries
  listOfListsOfFileEntries =
    lib.mapAttrsToList (
      name: value:
        generate-file-entries name
    )
    modified-cert-attributes;

  # 2. Flatten the list of lists into a single list of file entries
  flatListOfFileEntries = lib.flatten listOfListsOfFileEntries;

  # 3. Convert the flat list of entries into a single attribute set
  generatedFilesAttrSet = builtins.listToAttrs flatListOfFileEntries;

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
          vault_pki_secret_backend_root_cert = import ./root-cert.nix {
            inherit config;
          };
          vault_pki_secret_backend_issuer = import ./root-issuer.nix;
          vault_pki_secret_backend_config_urls = import ./config-urls.nix {
            inherit config;
          };

          # Intermediate CA backend config
          vault_pki_secret_backend_intermediate_cert_request = import ./csr-request.nix {
            inherit config;
          };
          vault_pki_secret_backend_root_sign_intermediate = import ./root-sign-intermediate.nix {
            inherit config;
          };
          vault_pki_secret_backend_intermediate_set_signed = import ./intermediate-set-signed.nix;

          # PKI Roles
          vault_pki_secret_backend_role = import ./role.nix {
            inherit config;
          };

          # Certificates
          vault_pki_secret_backend_cert = modified-cert-attributes;

          local_file =
            {
              root-cert = {
                content = "\${ vault_pki_secret_backend_root_cert.root-cert.certificate }";
                filename = "${cfg.pki.cert-output-dir}/root-cert.crt";
              };

              intermediate-cert = {
                content = "\${ vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate }";
                filename = "${cfg.pki.cert-output-dir}/intermediate-cert.crt";
              };
            }
            // generatedFilesAttrSet; # Generate local key/cert files for each cfg.pki.certs definition as well as root-cert and intermediate-cert
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

    cert-output-dir = mkOption {
      type = types.str;
      default = "/var/lib/vault/leaf-certs";
      description = ''
        Directory to output the certificates and private key to.

        Ensure that the value doesn't have a training "/"!
      '';
    };

    certs = mkOption {
      default = {};
      type = types.attrsOf (
        types.submodule (
          {...}: {
            options = {
              common_name = mkOption {
                type = types.str;
                default = "";
                description = "Common name of the server (e.g. website.example.com)";
              };

              ttl = mkOption {
                type = types.int;
                default = 7776000;
                description = ''
                  TTL of certificates (when they expire)

                  Default is 777600 (90 days)
                '';
              };
            };
          }
        )
      );
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

        ${
          if cfg.pki.certs != {}
          then "echo Setting permissions on leaf cert directory... \\
            && chmod 600 -R ${cfg.pki.cert-output-dir} \\
            && chown vault:vault -R ${cfg.pki.cert-output-dir}"
          else "echo Nothing else to do..."
        }
      '');
    };
  };
}
