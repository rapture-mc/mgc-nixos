{
  networking = import ./networking.nix;
  keys = import ./keys.nix;
  domains = import ./domains.nix;

  adminUser = "benny";
}
