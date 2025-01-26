{ pkgs, lib, config, inputs, home, bconfig, ... }: {
  programs.waybar = {
    enable = true;
    settings = {
      topBar = {
        output = [ bconfig.mine.waybar.monitor ];
        layer = "top";
        position = "top";
        height = 30;

        modules-center = [ "hyprland/workspaces" ];
        "hyprland/workspaces" = { on-click = "activate"; };
      };
      bottomBar = {
        output = [ bconfig.mine.waybar.monitor ];
        layer = "top";
        position = "bottom";
        height = 30;

        modules-left = [ "cpu" ];
        modules-center = [ "clock" ];
        modules-right = [ "memory" ];

        cpu = {
          interval = 10;
          format = " {}%";
        };
        clock = {
          interval = 1;
          format = "{:%H:%M:%S}";
        };
        memory = {
          interval = 30;
          format = "{}%";
          max-length = 10;
        };
      };
    };
  };
}
