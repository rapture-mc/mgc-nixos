{
  pkgs,
  osConfig,
  ...
}: let
  cyberpunk-theme = pkgs.stdenv.mkDerivation {
    name = "theme";

    src = pkgs.fetchFromGitHub {
      owner = "Roboron3042";
      repo = "Cyberpunk-Neon";
      rev = "eb7595459c0d4164262e0ccaf8d6e5c1936a6f67";
      sha256 = "sha256-whHBIxEGGvTPVUaE/HQDb/Qyl5sPMGlOmofgNCBaNng=";
    };

    installPhase = ''
      mkdir $out

      cp -rv $src/kde/cyberpunk-neon.colors $out
    '';
  };
in {
  home.file."cyberpunk-theme" = {
    enable = true;
    source = "${cyberpunk-theme}/cyberpunk-neon.colors";
    target = ".local/share/color-schemes/cyberpunk-neon.colors";
  };

  programs.plasma = {
    enable = true;

    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      wallpaper = ./desktop-wallpaper.jpg;
      colorScheme = "cyberpunk-neon";
    };

    kscreenlocker = {
      appearance.wallpaper = ./desktop-wallpaper.jpg;
      autoLock =
        if osConfig.megacorp.config.desktop.xrdp
        then false
        else true;
    };

    hotkeys.commands."launch-rofi" = {
      name = "Launch Rofi";
      key = "Meta+K";
      command = "rofi -normal-window -show-icons -show drun";
    };

    panels = [
      {
        opacity = "opaque";
        screen = "all";
      }
    ];

    powerdevil = {
      AC.autoSuspend.action = "nothing";
      battery.autoSuspend.action = "nothing";
      lowBattery.autoSuspend.action = "nothing";
    };
  };
}
