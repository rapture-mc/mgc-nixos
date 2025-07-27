{
  osConfig,
  lib,
  ...
}: let
  inherit
    (lib)
    mkIf
    ;
in {
  xdg.desktopEntries = {
    UnstoppableSwap = mkIf osConfig.megacorp.virtualisation.whonix.enable {
      name = "UnstoppableSwap";
      genericName = "XMR Swap";
      exec = "UnstoppableSwap";
      terminal = false;
      icon = ../../../../resources/unstoppable-swap.svg;
    };

    StartWhonix = mkIf osConfig.megacorp.virtualisation.whonix.enable {
      name = "Start Whonix";
      exec = "startWhonix";
      terminal = false;
      icon = ../../../../resources/whonix.svg;
    };

    StopWhonix = mkIf osConfig.megacorp.virtualisation.whonix.enable {
      name = "Stop Whonix";
      exec = "stopWhonix";
      terminal = false;
      icon = ../../../../resources/whonix.svg;
    };
  };
}
