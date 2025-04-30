{ pkgs, lib, config, inputs, home, bconfig, ... }: {
  home.packages = with pkgs; [ rofi ];
  programs.rofi = {
    enable = true;
    extraConfig = {
      modi = "drun";
      display-drun = "Run";
      sidebar-mode = false;
      # Window dimensions
      width = 50;
      lines = 10;
      # Padding and spacing
      padding = 400;
      border-radius = 8;
      # Positioning
      location = 0;
      anchor = "center";
      fixed-num-lines = true;
      window-format = "{w}";
    };
    theme = let inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "*" = {
        background-color = mkLiteral "@base00";
        text-color = mkLiteral "@base05";
      };

      "element-text, element-icon" = {
        background-color = mkLiteral "inherit";
        text-color = mkLiteral "inherit";
      };

      "window" = {
        border-radius = 8;
        background-color = mkLiteral "@base00";
      };

      "element selected" = {
        background-color = mkLiteral "@base02";
        text-color = mkLiteral "@base06";
      };
    };
  };
}
