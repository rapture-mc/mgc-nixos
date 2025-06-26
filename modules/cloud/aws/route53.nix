{
  lib,
  config,
  terranix,
  pkgs,
  system,
  ...
}: let
  cfg = config.megacorp.cloud.aws.route53;

  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  route53-config = terranix.lib.terranixConfiguration {
    inherit system;
    modules = [
      {
        terraform.required_providers.aws.source = "hashicorp/aws";

        provider.aws = {
          shared_credentials_files = ["${cfg.credential-path}"];
          shared_config_files = ["${cfg.config-path}"];
          region = cfg.region;
        };

        resource.aws_route53_record = cfg.records;
      }
    ];
  };
in {
  options.megacorp.cloud.aws.route53 = {
    enable = mkEnableOption "Enable AWS Route53 management";

    region = mkOption {
      type = types.str;
      default = "ap-southeast-2";
      description = "Region to deploy the resources too";
    };

    credential-path = mkOption {
      type = types.str;
      default = "";
      description = ''
        The full path to the aws credential path.

        E.g. "/home/<username>/.aws/credentials"
      '';
    };

    config-path = mkOption {
      type = types.str;
      default = "";
      description = ''
        The full path to the aws config path.

        E.g. "/home/<username>/.aws/config"
      '';
    };

    records = mkOption {
      default = {};
      type = types.attrsOf (
        types.submodule (
          {...}: {
            options = {
              zone_id = mkOption {
                type = types.str;
                default = "";
                description = "The zone id";
              };

              ttl = mkOption {
                type = types.int;
                default = 300;
                description = "The TTL for records";
              };

              name = mkOption {
                type = types.str;
                default = "";
                description = "The name of the record";
              };

              type = mkOption {
                type = types.str;
                default = "";
                description = "The type of record";
              };

              records = mkOption {
                type = types.listOf types.str;
                default = [];
                description = "A string list of records";
              };
            };
          }
        )
      );
    };
  };

  config = mkIf cfg.enable {
    systemd.services.aws-infra-provisioner = {
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      path = [pkgs.git];
      serviceConfig.ExecStart = toString (pkgs.writers.writeBash "generate-aws-json-config" ''
        if [[ -e config.tf.json ]]; then
          rm -f config.tf.json;
        fi
        cp ${route53-config} config.tf.json \
          && ${pkgs.opentofu}/bin/tofu init \
          && ${pkgs.opentofu}/bin/tofu apply -auto-approve
      '');
    };
  };
}
