_: {
  sops = {
    defaultSopsFile = ../../../sops/default.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/ben.harris/.config/sops/age/keys.txt";
    secrets = {
      mailserver-password-file = {};
    };
  };
}
