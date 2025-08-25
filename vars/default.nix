{
  networking = import ./networking.nix;
  keys = import ./keys.nix;
  domains = import ./domains.nix;
  users = import ./users.nix;
  adminUser = "benny";
}
