{vars}: {
  sops = {
    defaultSopsFile = ../../../sops/default.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/${vars.adminUser}/.config/sops/age/keys.txt";
    secrets = {
      postgres-password = {};
      semaphore-db-pass = {};
      semaphore-access-key-encryption = {};
      neo4j-auth = {};
      bhe-neo4j-connection = {};
      bhe-database-secret = {};
      snipe-keyfile = {
        owner = "snipeit";
        group = "snipeit";
      };
    };
  };
}
