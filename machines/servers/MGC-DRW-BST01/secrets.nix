{vars}: {
  sops = {
    defaultSopsFile = ../../../sops/default.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/${vars.adminUser}/.config/sops/age/keys.txt";
    secrets = {
      restic-repo-password = {};
      syncthing-admin-password = {
        owner = "ben.harris";
        sopsFile = ../../../sops/syncthing.yml;
      };
    };
  };
}
