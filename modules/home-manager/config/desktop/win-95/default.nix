_: {
  imports = [
    ./XFCE-Retro
    ./GUI-Apps
    ./desktop.nix
  ];

  # App groups
  standardApps.enable = true;
  officeApps.enable = true;

  # Individual applications
  brave-and-extension.enable = true;
  vscodium-and-extension.enable = true;
  vesktop.enable = true;
  krita.enable = true;
  signal.enable = true;
  spotify.enable = false;
  obsidian.enable = false;
  protonvpn.enable = true;

  # Gaming:
  prismlauncher.enable = true;
}
