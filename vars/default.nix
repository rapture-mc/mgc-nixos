{
  adminUser = "benny";
  domains = import ./domains.nix;
  keys = import ./keys.nix;
  networking = import ./networking.nix;
  syncthing = import ./syncthing.nix;
  users = import ./users.nix;
}
