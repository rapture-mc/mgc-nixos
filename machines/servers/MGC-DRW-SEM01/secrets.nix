{
  sops = {
    defaultSopsFile = ../../../sops/default.yml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/benny/.config/sops/age/keys.txt";
    secrets = {
      postgres-password.sopsFile = ../../../sops/semaphore.yml;
      semaphore-db-pass.sopsFile = ../../../sops/semaphore.yml;
      semaphore-access-key-encryption.sopsFile = ../../../sops/semaphore.yml;
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
