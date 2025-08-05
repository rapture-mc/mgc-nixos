{vars}: {
  megacorp.virtualisation.libvirt.hypervisor = {
    enable = true;
    logo = true;
    terraform.state-dir = "/var/lib/terranix-state/libvirt";
    libvirt-users = [
      "${vars.adminUser}"
      "ben.harris"
    ];
  };
}
