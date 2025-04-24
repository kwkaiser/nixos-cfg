{ pkgs, lib, config, inputs, home, bconfig, ... }: {
  programs.waybar = {
    enable = true;
    settings = {
      topBar = {
        output = [ bconfig.mine.waybar.monitor ];
        layer = "top";
        position = "top";
        height = 48;
        margin-top = 0;
        margin-bottom = 0;
        margin-left = 0;
        margin-right = 0;

        modules-center = [ "hyprland/workspaces" ];
        "hyprland/workspaces" = {
          on-click = "activate";
          format = "{name}";
          active-only = false;
        };
      };
      bottomBar = {
        output = [ bconfig.mine.waybar.monitor ];
        layer = "top";
        position = "bottom";
        height = 48;
        margin-top = 0;
        margin-bottom = 0;
        margin-left = 0;
        margin-right = 0;

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

    style = ''
      * {
        font-size: 11px;
        font-family: "JetBrainsMono Nerd Font";
      }

      window#waybar {
        background-color: @theme-base00;
        border-bottom: 1px solid @theme-base01;
      }

      /* WORKSPACE */
      #workspaces button {
        min-width: 8px;
        padding-left: 16px;
        padding-right: 16px;
        padding-top: 6px;
        padding-bottom: 6px;
        margin-top: 8px;
        margin-left: 4px;
        margin-right: 4px;
        border-radius: 7px;
        background-color: @theme-base01;
      }

      #workspaces button.active {
        background-color: @theme-base02;
      }

      /* SYS STATS */
      #cpu,
      #memory,
      #clock,
      #disk,
      #network {
        border-radius: 7px;
        font-size: 14px;
        min-width: 60px;
        padding-left: 32px;
        padding-right: 32px;
        margin-bottom: 8px;
        margin-left: 8px;
        margin-right: 8px;
        background-color: @theme-base01;
      }

      #network {
        padding-left: 6px;
        padding-right: 6px;
      }
    '';
  };
}
