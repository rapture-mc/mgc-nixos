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

        resource = {
          aws_route53_zone = cfg.zones;

          aws_route53_record = cfg.records;
        };
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

    state-dir = mkOption {
      type = types.path;
      default = "/var/lib/terranix/state/route53";
      description = "Where to store the Terranix state files";
    };

    zones = mkOption {
      default = {};
      type = types.attrsOf (
        types.submodule (
          {...}: {
            options = {
              name = mkOption {
                type = types.str;
                default = "";
                description = "The name of the zone";
              };
            };
          }
        )
      );
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
    systemd.services.aws-infra-route53-provisioner = {
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      path = with pkgs; [
        git
        opentofu
      ];
      serviceConfig.ExecStart = toString (pkgs.writers.writeBash "generate-aws-route53-config" ''
        if [ ! -d "${cfg.state-dir}" ]; then
          echo "Directory ${cfg.state-dir} doesn't exist... Creating..."
          mkdir -p ${cfg.state-dir}
          chown root:root ${cfg.state-dir}
        else
          echo "Directory ${cfg.state-dir} already exists... Skipping..."
        fi

        echo "Changing into ${cfg.state-dir}..."
        cd ${cfg.state-dir}

        if [[ -e config.tf.json ]]; then
          rm -f config.tf.json;
        fi
        cp ${route53-config} config.tf.json \
          && tofu init \
          && tofu plan
      '');
    };
  };
}
