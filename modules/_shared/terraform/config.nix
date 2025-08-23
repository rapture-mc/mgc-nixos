{
  cfg,
  pkgs,
  finalTerraformConfig,
}: {
  wantedBy = ["multi-user.target"];
  after = ["network-online.target"];
  wants = ["network-online.target"];
  path = with pkgs; [
    git
    opentofu
    libxslt
  ];
  serviceConfig.ExecStart = toString (pkgs.writers.writeBash "generate-terraform-json-config" ''
    if [ ! -d "${cfg.terraform.state-dir}" ]; then
      echo "Directory ${cfg.terraform.state-dir} doesn't exist... Creating..."
      mkdir -p ${cfg.terraform.state-dir}
      chown root:root ${cfg.terraform.state-dir}
    else
      echo "Directory ${cfg.terraform.state-dir} already exists... Skipping..."
    fi

    echo "Changing into ${cfg.terraform.state-dir}..."
    cd ${cfg.terraform.state-dir}

    if [[ -e config.tf.json ]]; then
      rm -f config.tf.json;
    fi
    cp ${finalTerraformConfig} config.tf.json \
      && tofu init \
      && tofu ${cfg.terraform.action} ${
      if (cfg.terraform.action == "apply" || cfg.terraform.action == "destroy")
      then "-auto-approve"
      else ""
    }
  '');
}
