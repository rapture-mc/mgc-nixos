{
  pkgs,
  terranix,
  system,
  ...
}: let
  terraformConfiguration = terranix.lib.terranixConfiguration {
    inherit system;
    modules = [
      {
        terraform.required_providers.aws.source = "hashicorp/aws";

        provider.aws = {
          shared_credentials_files = ["/home/benny/.aws/credentials"];
          shared_config_files = ["/home/benny/.aws/config"];
          region = "ap-southeast-2";
        };

        resource = {
          aws_s3_bucket.example_bucket = {
            bucket = "sickest-bucket-out";
          };

          # aws_s3_bucket_acl.example_acl = {
          #   depends_on = ["aws_s3_bucket.example_bucket"];
          #   bucket = "\${ aws_s3_bucket.example_bucket.id }";
          #   acl = "private";
          # };
        };
      }
    ];
  };
in {
  systemd.services.aws-infra = {
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    path = [pkgs.git];
    serviceConfig.ExecStart = toString (pkgs.writers.writeBash "generate-aws-config" ''
      if [[ -e config.tf.json ]]; then
        rm -f config.tf.json;
      fi
      cp ${terraformConfiguration} config.tf.json \
        && ${pkgs.opentofu}/bin/tofu init \
        && ${pkgs.opentofu}/bin/tofu apply -auto-approve
    '');
  };
}
