{
  megacorp.cloud.aws.ec2 = {
    enable = true;
    credential-path = "/home/ben.harris/.aws/credentials";
    config-path = "/home/ben.harris/.aws/config";
    terraform.state-dir = "/var/lib/terranix-state/aws/ec2";
    ssh-public-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzlYmoWjZYFeCNdMBCHBXmqpzK1IBmRiB3hNlsgEtre benny@MGC-DRW-BST01";
    ingress-rules = [
      {
        from_port = 22;
        to_port = 22;
        description = "Allow SSH in";
      }

      {
        from_port = 80;
        to_port = 80;
        description = "Allow HTTP in";
      }

      {
        from_port = 443;
        to_port = 443;
        description = "Allow HTTPS in";
      }

      {
        from_port = 21115;
        to_port = 21119;
        description = "Allow RustDesk TCP in";
      }

      {
        from_port = 21116;
        to_port = 21116;
        protocol = "udp";
        description = "Allow RustDesk UDP in";
      }
    ];
    machines = {
      headscale-server = {
        instance_type = "t2.medium";
        create_eip = true;
        root_block_device.size = 100;
      };
    };
  };
}
