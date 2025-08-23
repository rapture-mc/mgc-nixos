{
  megacorp.cloud.aws.ec2 = {
    enable = true;
    credential-path = "/home/ben.harris/.aws/credentials";
    config-path = "/home/ben.harris/.aws/config";
    terraform.state-dir = "/var/lib/terranix-state/aws/ec2";
    machines = {
      mail-server = {
        instance_type = "t2.medium";
        # associate_public_ip_address = true;
        create_eip = true;
        root_block_device.size = 100;
      };
    };
  };
}
