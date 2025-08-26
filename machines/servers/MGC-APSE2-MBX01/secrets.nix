{
  sops = {
    defaultSopsFile = ../../../sops/default.yml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/ben.harris/.config/sops/age/keys.txt";
    secrets = {
      mailserver-password-file = {};
    };
  };
}
