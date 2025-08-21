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
              values = ["nixos/${cfg.instance.nixos-version}*"];
            }
            {
              name = "architecture";
              values = ["x86_64"];
            }
          ];
        };

        resource = {
          # aws_instance.nixos_x86-64 = {
          #   ami = "\${ data.aws_ami.nixos-x86_64.id }";
          #   instance_type = cfg.instance.instance-type;
          #   subnet_id = "\${ aws_subnet.nix-subnet.id }";
          #   associate_public_ip_address = true;
          #   key_name = "\${ aws_key_pair.default.key_name }";
          #   vpc_security_group_ids = [
          #     "\${ aws_security_group.default.id }"
          #   ];
          #   root_block_device = {
          #     volume_size = cfg.instance.disk-size;
          #   };
          # };

          aws_key_pair.default = {
            key_name = "default-key";
            public_key = cfg.instance.public-key;
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

    terraform = import ../../_shared/terraform/options.nix {
      inherit lib;
    };

    machines = mkOption {
      default = null;
      type = types.nullOr (types.attrsOf (
        types.submodule (
          _: {
            instance-type = mkOption {
              type = types.str;
              default = "t2.medium";
              description = "Instance type";
            };

            nixos-version = mkOption {
              type = types.str;
              default = "25.05";
              description = "The NixOS version";
            };

            disk-size = mkOption {
              type = types.str;
              default = "30";
              description = "The size of the VM disk";
            };

            public-key = mkOption {
              type = types.str;
              default = "";
              description = "The SSH public key authorized to connect to the instance (using root account)";
            };
          }
        )
      ));
    };

    # instance = {
    #   enable = mkEnableOption "Enable AWS instance";
    #
    #   instance-type = mkOption {
    #     type = types.str;
    #     default = "t2.medium";
    #     description = "Instance type";
    #   };
    #
    #   nixos-version = mkOption {
    #     type = types.str;
    #     default = "25.05";
    #     description = "The NixOS version";
    #   };
    #
    #   disk-size = mkOption {
    #     type = types.str;
    #     default = "30";
    #     description = "The size of the VM disk";
    #   };
    #
    #   public-key = mkOption {
    #     type = types.str;
    #     default = "";
    #     description = "The SSH public key authorized to connect to the instance (using root account)";
    #   };
    # };
  };

  config = mkIf cfg.enable {
    systemd.services.aws-infra-ec2-provisioner = import ../../_shared/terraform/config.nix {
      inherit cfg pkgs terraform-config;
    };
  };
}
