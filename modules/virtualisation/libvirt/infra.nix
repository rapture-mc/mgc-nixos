{ lib, config, terranix, pkgs, system, ... }: let
  cfg = config.megacorp.virtualisation.libvirt;

  terraform-module-source = "git::https://github.com/rapture-mc/terraform-libvirt-module.git?ref=40acff807a0ffb1c0da741774c37ebeda90730b7";

  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types;

  libvirt-config = terranix.lib.terranixConfiguration {
    inherit system;
    modules = [
      {
        terraform.required_providers.libvirt.source = "dmacvicar/libvirt";

        provider.libvirt.uri = "qemu:///system";

        module = {
          bastion-server = {
            source = terraform-module-source;
            vm_hostname_prefix = "MGC-DRW-BST";
            uefi_enabled = false;
            autostart = true;
            vm_count = 1;
            memory = "6144";
            vcpu = 2;
            system_volume = 100;
            bridge = "br0";
            dhcp = true;
          };
        };
      }
    ];
  };
in {
  options.megacorp.virtualisation.libvirt.infra = {
    enable = mkEnableOption "Enable libvirt infra provisioner";

    instance = {
      enable = mkEnableOption "Enable AWS instance";

      vm_count = mkOption {
        type = types.int;
        default = 1;
        description = "How many VMs to provision";
      };

      disk-size = mkOption {
        type = types.str;
        default = "30";
        description = "The size of the VM disk";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.libvirt-infra-provisioner = {
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      path = [pkgs.git];
      serviceConfig.ExecStart = toString (pkgs.writers.writeBash "generate-libvirt-json-config" ''
        if [[ -e config.tf.json ]]; then
          rm -f config.tf.json;
        fi
        cp ${libvirt-config} config.tf.json \
          && ${pkgs.opentofu}/bin/tofu init \
          && ${pkgs.opentofu}/bin/tofu ${if cfg.instance.enable then "apply" else "destroy"} -auto-approve
      '');
    };
  };
}
