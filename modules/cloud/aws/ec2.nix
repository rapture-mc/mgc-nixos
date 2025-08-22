{
  lib,
  config,
  terranix,
  pkgs,
  system,
  ...
}: let
  cfg = config.megacorp.cloud.aws.ec2;

  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  static-terraform-config = {
    source  = "terraform-aws-modules/ec2-instance/aws";
    ami = "\${ data.aws_ami.nixos-x86_64.id }";
    key_name = "\${ aws_key_pair.default.key_name }";
    subnet_id = "\${ aws_subnet.nix-subnet.id }";
    vpc_security_group_ids = [
      "\${ aws_security_group.default.id }"
    ];
  };

  transformed-terraform-config =
    lib.mapAttrs (
      name: value:
        if lib.isAttrs value
        then value // static-terraform-config
        else value
    )
    cfg.machines;

  terraform-config = terranix.lib.terranixConfiguration {
    inherit system;
    modules = [
      {
        terraform.required_providers.aws.source = "hashicorp/aws";

        provider.aws = {
          shared_credentials_files = ["${cfg.credential-path}"];
          shared_config_files = ["${cfg.config-path}"];
          region = cfg.region;
        };

        data.aws_ami.nixos-x86_64 = {
          owners = ["427812963091"];
          most_recent = true;
          filter = [
            {
              name = "name";
              values = ["nixos/25.05*"];
            }
            {
              name = "architecture";
              values = ["x86_64"];
            }
          ];
        };

        module = transformed-terraform-config;

        resource = {
          aws_key_pair.default = {
            key_name = "default-key";
            public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzlYmoWjZYFeCNdMBCHBXmqpzK1IBmRiB3hNlsgEtre benny@MGC-DRW-BST01";
          };

          aws_vpc.nix-vpc = {
            cidr_block = "10.10.0.0/24";
          };

          aws_subnet.nix-subnet = {
            vpc_id = "\${ aws_vpc.nix-vpc.id }";
            cidr_block = "10.10.0.0/25";
            availability_zone = "${cfg.region}a";
          };

          aws_internet_gateway.nix-gateway = {
            vpc_id = "\${ aws_vpc.nix-vpc.id }";
          };

          aws_route_table.nix-route-tb = {
            vpc_id = "\${ aws_vpc.nix-vpc.id }";
          };

          aws_route_table_association.nix-subnet-route-tb-association = {
            subnet_id = "\${ aws_subnet.nix-subnet.id }";
            route_table_id = "\${ aws_route_table.nix-route-tb.id }";
          };

          aws_route.internet-route = {
            destination_cidr_block = "0.0.0.0/0";
            route_table_id = "\${ aws_route_table.nix-route-tb.id }";
            gateway_id = "\${ aws_internet_gateway.nix-gateway.id }";
          };

          aws_security_group.default = {
            vpc_id = "\${ aws_vpc.nix-vpc.id }";

            ingress = [
              {
                description = "Allow SSH in";
                from_port = 22;
                to_port = 22;
                protocol = "tcp";
                cidr_blocks = ["0.0.0.0/0"];
                ipv6_cidr_blocks = [];
                prefix_list_ids = [];
                security_groups = [];
                self = false;
              }
            ];

            egress = [
              {
                description = "Allow all traffic out";
                from_port = 0;
                to_port = 0;
                protocol = "-1";
                cidr_blocks = ["0.0.0.0/0"];
                ipv6_cidr_blocks = [];
                prefix_list_ids = [];
                security_groups = [];
                self = false;
              }
            ];
          };
        };
      }
    ];
  };
in {
  options.megacorp.cloud.aws.ec2 = {
    enable = mkEnableOption "Enable AWS provisioner";

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

    key-pair = mkOption {
      type = types.str;
      default = "";
    };

    terraform = import ../../_shared/terraform/options.nix {
      inherit lib;
    };

    machines = mkOption {
      default = null;
      type = types.nullOr (types.attrsOf (
        types.submodule (
          { name, ...}: {
            options = {
              name = mkOption {
                type = types.str;
                default = name;
              };

              instance_type = mkOption {
                type = types.str;
                default = "t2.medium";
                description = "Instance type";
              };

              associate_public_ip_address = mkOption {
                type = types.bool;
                default = false;
              };

              root_block_device = mkOption {
                default = null;
                type = types.nullOr (types.submodule (
                  _: {
                    options = {
                      encrypted = mkOption {
                        type = types.bool;
                        default = false;
                      };

                      size = mkOption {
                        type = types.int;
                        default = 5;
                      };
                    };
                  }
                ));
              };
            };
          }
        )
      ));
    };
  };

  config = mkIf cfg.enable {
    systemd.services.aws-infra-ec2-provisioner = import ../../_shared/terraform/config.nix {
      inherit cfg pkgs terraform-config;
    };
  };
}
