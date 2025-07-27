{pkgs, ...}: {
  environment.systemPackages = [
    (pkgs.callPackage ./sddm-astronaut-theme.nix {
      theme = "cyberpunk";
      themeConfig.General = {
        Background = "${../../../../resources/desktop-wallpaper.jpg}";
        HeaderText = "System Locked...";
        DateFormat = "dd/M";
      };
    })
  ];

  services = {
    desktopManager.plasma6.enable = true;
    xserver = {
      enable = true;
      xkb.layout = "au";
    };
    displayManager.sddm = {
      enable = true;
      theme = "sddm-astronaut-theme";
      extraPackages = [
        pkgs.kdePackages.qtmultimedia
        pkgs.kdePackages.qtsvg
        pkgs.kdePackages.qtvirtualkeyboard
      ];
    };
  };
}
