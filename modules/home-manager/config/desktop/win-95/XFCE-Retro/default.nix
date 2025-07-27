{
  pkgs,
  lib,
  ...
}: let
  
  chicago95 = pkgs.callPackage ../../../../../../resources/Themes/Chicago95/chicago95.nix {};
  dotfilesPath = ./dotfiles;
  resourcesPath = ../../../../../../resources;
  wallpaperFile = "Wallpaper/NixOS-95-wallpaper.png";
  wallpaperOrigin = "${resourcesPath}/desktop-wallpaper.jpg";
  dotfiles = "${dotfilesPath}";
in {
  gtk = {
    enable = true;
    theme = {
      name = "Chicago95";
      package = chicago95;
    };
    iconTheme = {
      name = "Win95_plus";
      package = pkgs.callPackage ../../../../../../resources/Themes/Win95_plus/win95_plus.nix {};
    };
    cursorTheme = {
      name = "Chicago95";
      package = chicago95;
    };
    font = {
      name = "Sans";
      size = 12;
    };
  };

  home.pointerCursor = {
    name = "Chicago95";
    package = chicago95;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  home.packages = with pkgs; [
    xfce.xfce4-panel
    xfce.xfconf
    xfce.xfdesktop
    xfce.xfce4-whiskermenu-plugin
    xfce.xfce4-docklike-plugin
    xorg.xrandr
  ];

  home.file = {
    "${wallpaperFile}" = {
      source = wallpaperOrigin;
    };
  };

  xdg.configFile = {
    "xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml".source = "${dotfiles}/xfce4-desktop.xml";
    "xfce4/xfconf/xfce-perchannel-xml/xfce4-sessions.xml".source = "${dotfiles}/xfce4-sessions.xml";
    "xfce4/xfconf/xfce-perchannel-xml/xsettings.xml".source = "${dotfiles}/xsettings.xml";
    "xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml".source = "${dotfiles}/xfwm4.xml";
    "xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml".source = "${dotfiles}/xfce4-keyboard-shortcuts.xml";

    # Panel:
    "xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml".source = "${dotfiles}/xfce4-panel.xml";
    "xfce4/panel/launcher-13/brave.desktop".source = "${dotfiles}/launcher-13/brave.desktop";
    "xfce4/panel/launcher-14/signal.desktop".source = "${dotfiles}/launcher-14/signal.desktop";
    "xfce4/panel/launcher-15/obsidian.desktop".source = "${dotfiles}/launcher-15/obsidian.desktop";
    "xfce4/panel/launcher-16/spotify.desktop".source = "${dotfiles}/launcher-16/spotify.desktop";

  
  };

  home.activation.applyXfceTweaks = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ${pkgs.xfce.xfdesktop}/bin/xfdesktop --reload
  '';
}
