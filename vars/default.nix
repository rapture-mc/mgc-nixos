{
  networking = import ./networking.nix;
  keys = import ./keys.nix;
  domains = import ./domains.nix;

  adminUser = "benny";

  terraformModuleSource = "git::https://github.com/rapture-mc/terraform-libvirt-module.git?ref=40acff807a0ffb1c0da741774c37ebeda90730b7";
}
