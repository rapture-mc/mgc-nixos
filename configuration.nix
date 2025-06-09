{ pkgs, ... }:

{
  megacorp.config = {
    nixvim.enable = true;
    packages.enable = true;
    users = {
      enable = true;
      admin-user = "benny";
    };
    openssh = {
      enable = true;
      authorized-ssh-keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKhKBbO3gu8cbKQYOopVAA9gkSHHChkjMYPgfW2NIBrN benny@MGC-LT01"
      ];
    };
  };

  megacorp.virtualisation.aws = {
    enable = true;
    credential-path = "/home/benny/.aws/credentials";
    config-path = "/home/benny/.aws/config";
    instance = {
      enable = false;
      public-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKhKBbO3gu8cbKQYOopVAA9gkSHHChkjMYPgfW2NIBrN benny@MGC-LT01";
    };
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-dev";

  networking.networkmanager.enable = true;

  time.timeZone = "Australia/Darwin";

  i18n.defaultLocale = "en_AU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  services.xserver.xkb = {
    layout = "au";
    variant = "";
  };

  users.users.benny = {
    isNormalUser = true;
    description = "other";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  services.openssh.enable = true;

  system.stateVersion = "24.05";
}
