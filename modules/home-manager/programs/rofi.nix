{config, ...}: {
  programs.rofi = {
    enable = true;
    pass.enable = true;
    theme = let
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "*" = {
        bg = mkLiteral "#24283b";
        hv = mkLiteral "#9274ca";
        primary = mkLiteral "#C5C8C6";
        ug = mkLiteral "#0B2447";
        font = "Monospace 16";
        background-color = mkLiteral "@bg";
        border = mkLiteral "0px";
        kl = mkLiteral "#7aa2f7";
        black = mkLiteral "#000000";
        transparent = mkLiteral "rgba(46,52,64,0)";
      };

      "window" = {
        width = 700;
        orientation = mkLiteral "horizontal";
        location = mkLiteral "center";
        anchor = mkLiteral "center";
        transparency = "screenshot";
        border-color = mkLiteral "@transparent";
        border = mkLiteral "0px";
        border-radius = mkLiteral "6px";
        spacing = 0;
        children = [(mkLiteral "mainbox")];
      };

      "mainbox" = {
        spacing = 0;
        children = [
          (mkLiteral "inputbar")
          (mkLiteral "message")
          (mkLiteral "listview")
        ];
      };

      "inputbar" = {
        color = mkLiteral "@kl";
        padding = mkLiteral "11px";
        border = mkLiteral "3px 3px 2px 3px";
        border-color = mkLiteral "@primary";
        border-radius = mkLiteral "6px 6px 0px 0px";
      };

      "message" = {
        padding = 0;
        border-color = mkLiteral "@primary";
        border = mkLiteral "0px 1px 1px 1px";
      };

      "entry, prompt, case-indicator" = {
        text-font = mkLiteral "inherit";
        text-color = mkLiteral "inherit";
      };

      "entry" = {
        cursor = mkLiteral "pointer";
      };

      "prompt" = {
        margin = mkLiteral "0px 5px 0px 0px";
      };

      "listview" = {
        layout = mkLiteral "vertical";
        padding = mkLiteral "5px";
        lines = 12;
        colums = 1;
        border = mkLiteral "0px 3px 3px 3px";
        border-radius = mkLiteral "0px 0px 6px 6px";
        border-color = mkLiteral "@primary";
        dynamic = mkLiteral "false";
      };

      "element" = {
        padding = mkLiteral "2px";
        vertical-align = 1;
        color = mkLiteral "@kl";
        font = mkLiteral "inherit";
      };

      "element-text" = {
        background-color = mkLiteral "inherit";
        text-color = mkLiteral "inherit";
      };

      "element selected.normal" = {
        color = mkLiteral "@black";
        background-color = mkLiteral "@hv";
      };

      "element normal active" = {
        background-color = mkLiteral "@hv";
        color = mkLiteral "@black";
      };

      "element-text, element-icon" = {
        background-color = mkLiteral "inherit";
        text-color = mkLiteral "inherit";
      };

      "element normal urgent" = {
        background-color = mkLiteral "@primary";
      };

      "element selected active" = {
        background = mkLiteral "@hv";
        foreground = mkLiteral "@bg";
      };

      "button" = {
        padding = mkLiteral "6px";
        color = mkLiteral "@primary";
        horizontal-align = mkLiteral "0.5";
        border = mkLiteral "2px 0px 2px 2px";
        border-radius = mkLiteral "4px 0px 0px 4px";
        border-color = mkLiteral "@primary";
      };

      "button selected normal" = {
        border = mkLiteral "2px 0px 2px 2px";
        border-color = mkLiteral "@primary";
      };

      "scrollbar" = {
        enabled = mkLiteral "true";
      };
    };
  };
}
