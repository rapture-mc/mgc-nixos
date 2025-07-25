{
  config,
  lib,
  pkgs,
  terranix,
  system,
  ...
}: let
  cfg = config.megacorp.virtualisation.libvirt.hypervisor;

  inherit
    (lib)
    types
    mkOption
    mkIf
    ;

  terraform-module.source = "git::https://github.com/rapture-mc/terraform-libvirt-module.git?ref=c303bdb7b5e12a1701be16181b0647cc9e358d6d";

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

        resource.libvirt_pool.default = {
          name = "default";
          type = "dir";
          target = {
            path = "/var/lib/libvirt/images";
          };
        };

        module = transformed-terraform-config;
      }
    ];
  };
in {
  options.megacorp.virtualisation.libvirt.hypervisor = {
    terraform = import ../../_shared/terraform/options.nix {
      inherit lib;
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
      default = null;
      type = types.nullOr (types.attrsOf (
        types.submodule (
          _: {
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

              index_start = mkOption {
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
      ));
    };
  };

  config = mkIf (cfg.machines != null) {
    systemd.services = {
      libvirt-infra-provisioner = import ../../_shared/terraform/config.nix {
        inherit cfg pkgs terraform-config;
      };

      libvirt-ensure-pool-dir-exists = {
        after = ["libvirtd.service"];
        before = ["libvirt-infra-provisioner.service"];
        wantedBy = ["multi-user.target"];
        serviceConfig.ExecStart = toString (pkgs.writers.writeBash "libvirt-create-pool-dir" ''
          if [ ! -d "/var/lib/libvirt/images" ]; then
            echo "Directory /var/lib/libvirt/images doesn't exist... Creating..."
            mkdir -p /var/lib/libvirt/images
            chown root:root /var/lib/libvirt/images
          else
            echo "Directory /var/lib/libvirt/images already exists... Skipping..."
          fi
        '');
      };
    };
  };
}
