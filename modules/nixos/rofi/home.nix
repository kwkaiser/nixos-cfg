{ pkgs, lib, config, inputs, home, bconfig, ... }: {
  home.packages = with pkgs; [ rofi ];
  programs.rofi = {
    enable = true;
    extraConfig = {
      modi = "drun";
      display-drun = "Run";
      sidebar-mode = false;
    };
    theme = let inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "window" = {
        transparency = mkLiteral ''"real"'';
        border-radius = mkLiteral "7px";
        width = mkLiteral "50%";
        padding = mkLiteral "5px";
        border = mkLiteral "1px";
      };

      "prompt" = {
        enabled = true;
        horizontal-align = mkLiteral "0.5";
        vertical-align = mkLiteral "0.5";
        border = mkLiteral "2px";
        border-radius = mkLiteral "7px";
        padding = mkLiteral "0 1% 0";
      };

      "entry" = {
        placeholder = ''"search"'';
        expand = true;
        padding = mkLiteral "2%";
        border = mkLiteral "2px";
        border-radius = mkLiteral "7px";
        cursor = mkLiteral "text";
      };

      "inputbar" = {
        children = map mkLiteral [ "prompt" "entry" ];
        expand = false;
        spacing = mkLiteral "1%";
      };

      "listview" = {
        columns = 1;
        lines = 12;
        cycle = false;
        dynamic = true;
        layout = mkLiteral "vertical";
      };

      "mainbox" = {
        children = map mkLiteral [ "inputbar" "listview" ];
        spacing = mkLiteral "1%";
        padding = mkLiteral "1% 1% 1% 1%";
      };

      "element" = {
        orientation = mkLiteral "vertical";
        border-radius = mkLiteral "7px";
        padding = mkLiteral "1% 1%";
      };

      "element-text" = {
        expand = true;
        vertical-align = mkLiteral "0.5";
      };

      "element selected" = { border-radius = mkLiteral "7px"; };

      "listview, element, element selected, element-icon, element-text" = {
        cursor = mkLiteral "pointer";
      };
    };
  };
}
