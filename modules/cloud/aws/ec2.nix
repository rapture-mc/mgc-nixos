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

  staticIngressRulesConfig = {
    ipv6_cidr_blocks = [];
    prefix_list_ids = [];
    security_groups = [];
    self = false;
  };

  transformedIngressRulesConfig = builtins.map (value: value // staticIngressRulesConfig) cfg.ingress-rules;

  staticTerraformModuleConfig = {
    source  = "terraform-aws-modules/ec2-instance/aws";
    ami = "\${ data.aws_ami.nixos-x86_64.id }";
    key_name = "\${ aws_key_pair.default.key_name }";
    subnet_id = "\${ aws_subnet.nix-subnet.id }";
    associate_public_ip_address = true;
    vpc_security_group_ids = [
      "\${ aws_security_group.default.id }"
    ];
  };

  transformedTerraformModuleConfig =
    lib.mapAttrs (
      name: value:
        if lib.isAttrs value
        then value // staticTerraformModuleConfig
        else value
    )
    cfg.machines;

  finalTerraformConfig = terranix.lib.terranixConfiguration {
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

        module = transformedTerraformModuleConfig;

        resource = {
          aws_key_pair.default = {
            key_name = "default-key";
            public_key = cfg.ssh-public-key;
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
            ingress = transformedIngressRulesConfig;

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

    ssh-public-key = mkOption {
      type = types.str;
      default = "";
    };

    terraform = import ../../_shared/terraform/options.nix {
      inherit lib;
    };

    ingress-rules = mkOption {
      description = ''
        Ingress firewall rules for the entire subnet.

        Default is to allow SSH inbound for basic connectivity to the subnet.
      '';
      default = [
        {
          description = "Allow SSH inbound";
          from_port = 22;
          to_port = 22;
        }
      ];
      type = types.listOf (types.submodule (
        _: {
          options = {
            description = mkOption {
              type = types.str;
              default = "";
            };

            from_port = mkOption {
              type = types.int;
              description = "Incoming port";
            };

            to_port = mkOption {
              type = types.int;
              description = "Destination port";
            };

            protocol = mkOption {
              type = types.enum [
                "tcp"
                "udp"
              ];
              default = "tcp";
              description = "Transport protocol";
            };

            cidr_blocks = mkOption {
              type = types.listOf types.str;
              default = [
                "0.0.0.0/0"
              ];
              description = "Allowed source IP's in CIDR notation";
            };
          };
        }
      ));
    };

    machines = mkOption {
      default = null;
      type = types.nullOr (types.attrsOf (
        types.submodule (
          { name, ... }: {
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

              create_eip = mkOption {
                type = types.bool;
                default = false;
              };

              disable_api_termination = mkOption {
                type = types.bool;
                default = false;
                description = "Prevent instance from accidental termination";
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
      inherit cfg pkgs finalTerraformConfig;
    };
  };
}
