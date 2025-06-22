{vars}: {
  sops = {
    defaultSopsFile = ../../../sops/default.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/${vars.adminUser}/.config/sops/age/keys.txt";
    secrets = {
      netbox-key-file = {
        owner = "netbox";
        group = "netbox";
      };
    };
  };
}
