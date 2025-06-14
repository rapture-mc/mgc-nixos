{
  networking = import ./networking.nix;

  terraformModuleSource = "git::https://github.com/rapture-mc/terraform-libvirt-module.git?ref=40acff807a0ffb1c0da741774c37ebeda90730b7";

  keys = import ./keys.nix;

  adminUser = "benny";

  guacamoleFQDN = "guacamole.megacorp.industries";
  file-browserFQDN = "file-browser.megacorp.industries";
}
