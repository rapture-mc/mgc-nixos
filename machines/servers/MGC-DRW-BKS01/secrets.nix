{vars}: {
  sops = {
    defaultSopsFile = ../../../sops/default.yml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/${vars.adminUser}/.config/sops/age/keys.txt";
    secrets = {
      bookstack-keyfile = {
        owner = "bookstack";
        group = "bookstack";
      };
    };
  };
}
