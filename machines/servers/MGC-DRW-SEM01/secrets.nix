{vars}: {
  sops = {
    defaultSopsFile = ../../../sops/default.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/${vars.adminUser}/.config/sops/age/keys.txt";
    secrets = {
      postgres-password = {};
      semaphore-db-pass = {};
      semaphore-access-key-encryption = {};
      snipe-keyfile = {
        user = "snipeit";
        owner = "snipeit";
      };
    };
  };
}
