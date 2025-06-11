{
  pkgs,
  vars,
  terranix,
  system,
  ...
}: let
  terraformConfiguration = terranix.lib.terranixConfiguration {
    inherit system;
    modules = [
      {
        terraform.required_providers.libvirt.source = "dmacvicar/libvirt";

        provider.libvirt.uri = "qemu:///system";

        module = {
          bastion-server = {
            source = "${vars.terraformModuleSource}";
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

          domain-controller = {
            source = "${vars.terraformModuleSource}";
            vm_hostname_prefix = "MGC-DRW-DMC";
            uefi_enabled = false;
            autostart = true;
            vm_count = 1;
            memory = "4096";
            vcpu = 2;
            system_volume = 100;
            bridge = "br0";
            dhcp = true;
          };

          reverse-proxy = {
            source = "${vars.terraformModuleSource}";
            vm_hostname_prefix = "MGC-DRW-RVP";
            uefi_enabled = false;
            autostart = true;
            vm_count = 1;
            memory = "4096";
            vcpu = 2;
            system_volume = 100;
            bridge = "br0";
            dhcp = true;
          };

          desktop-gateway = {
            source = "${vars.terraformModuleSource}";
            vm_hostname_prefix = "MGC-DRW-DGW";
            uefi_enabled = false;
            autostart = true;
            vm_count = 1;
            memory = "4096";
            vcpu = 2;
            system_volume = 100;
            bridge = "br0";
            dhcp = true;
          };

          file-browser = {
            source = "${vars.terraformModuleSource}";
            vm_hostname_prefix = "MGC-DRW-FBR";
            uefi_enabled = false;
            autostart = true;
            vm_count = 1;
            memory = "4096";
            vcpu = 2;
            system_volume = 300;
            bridge = "br0";
            dhcp = true;
          };
        };
      }
    ];
  };
in {
  systemd.services.libvirt-infra = {
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    path = [pkgs.git];
    serviceConfig.ExecStart = toString (pkgs.writers.writeBash "generate-terranix-config" ''
      if [[ -e config.tf.json ]]; then
        rm -f config.tf.json;
      fi
      cp ${terraformConfiguration} config.tf.json \
        && ${pkgs.opentofu}/bin/tofu init \
        && ${pkgs.opentofu}/bin/tofu apply -auto-approve
    '');
  };
}
