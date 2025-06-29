{
  config,
  lib,
  pkgs,
  terranix,
  system,
  ...
}: let
  cfg = config.megacorp.virtualisation.libvirt.declerative;

  inherit
    (lib)
    types
    mkEnableOption
    mkOption
    mkIf
    ;

  terraform-module.source = "git::https://github.com/rapture-mc/terraform-libvirt-module.git?ref=40acff807a0ffb1c0da741774c37ebeda90730b7";

  transformed-terraform-config =
    lib.mapAttrs (
      name: value:
        if lib.isAttrs value
        then value // terraform-module
        else value
    )
    cfg.machines;

  terraform-config = terranix.lib.terranixConfiguration {
    inherit system;
    modules = [
      {
        terraform.required_providers.libvirt.source = "dmacvicar/libvirt";

        provider.libvirt.uri = "qemu:///system";

        module = transformed-terraform-config;
      }
    ];
  };
in {
  options.megacorp.virtualisation.libvirt.declerative = {
    enable = mkEnableOption "Whether to enable declerative VMs";

    action = mkOption {
      type = types.enum [
        "apply"
        "destroy"
        "plan"
      ];
      default = "apply";
      description = "What Terraform action to perform";
    };

    machines = mkOption {
      description = ''
        Attribute set of declerative machines to create.

        Example:
        machines = {
          bastion-servers = {
            vm_hostname_prefix = "prod-aus-bst-";
            vcpu = 2;
            memory = 2048;
          };

          file-servers = {
            vm_hostname_prefix = "prod-aus-fls-";
            vm_count = 2;
          };
        };

      '';
      type = types.attrsOf (
        types.submodule (
          {...}: {
            options = {
              vm_hostname_prefix = mkOption {
                type = types.str;
                default = "vm-";
              };

              os_img_url = mkOption {
                type = types.str;
                default = "/var/lib/libvirt/images/nixos.qcow2";
              };

              vm_count = mkOption {
                type = types.int;
                default = 1;
              };

              uefi_enabled = mkOption {
                type = types.bool;
                default = false;
              };

              autostart = mkOption {
                type = types.bool;
                default = true;
              };

              running = mkOption {
                type = types.bool;
                default = true;
              };

              memory = mkOption {
                type = types.str;
                default = "4096";
              };

              vcpu = mkOption {
                type = types.int;
                default = 1;
              };

              system_volume = mkOption {
                type = types.int;
                default = 100;
              };

              bridge = mkOption {
                type = types.str;
                default = "br0";
              };

              dhcp = mkOption {
                type = types.bool;
                default = true;
              };
            };
          }
        )
      );
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

        cp ${terraform-config} config.tf.json \
          && ${pkgs.opentofu}/bin/tofu init \
          && ${pkgs.opentofu}/bin/tofu ${cfg.action} ${
          if (cfg.action == "apply" || cfg.action == "destroy")
          then "-auto-approve"
          else ""
        }
      '');
    };
  };
}
