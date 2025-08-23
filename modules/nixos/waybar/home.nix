{ pkgs, lib, config, inputs, home, bconfig, ... }: {
  programs.waybar = {
    enable = true;
    settings = let
      mainConfig = {
        mainBar = {
          output = [ bconfig.mine.waybar.primaryMonitor "moonlight" ];
          layer = "top";
          position = "top";
          height = 48;
          margin = "0";

          modules-center = [ "hyprland/workspaces" ];
          modules-right = [ "custom/notification" ];

          "hyprland/workspaces" = {
            on-click = "activate";
            format = "{name}";
            active-only = false;
          };

          "custom/notification" = {
            "tooltip" = false;
            "format" = "notifs";
            "format-icons" = {
              "notification" = "";
              "none" = "";
              "dnd-notification" = "";
              "dnd-none" = "";
              "inhibited-notification" = "";
              "inhibited-none" = "";
              "dnd-inhibited-notification" = "";
              "dnd-inhibited-none" = "";
            };
            "return-type" = "json";
            "exec-if" = "which swaync-client";
            "exec" = "swaync-client -swb";
            "on-click" = "swaync-client -t -sw";
            "on-click-right" = "swaync-client -d -sw";
            "escape" = true;
          };
        };

        bottomBar = {
          output = [ bconfig.mine.waybar.primaryMonitor "moonlight" ];
          layer = "top";
          position = "bottom";
          height = 48;
          margin = "0";

          modules-left = [ "cpu" ];
          modules-center = [ "clock" ];
          modules-right = [ "disk" ];

          cpu = {
            interval = 10;
            format = " {}%";
          };
          clock = {
            interval = 1;
            format = "{:%H:%M:%S}";
          };
          disk = {
            interval = 30;
            format = "󰋊 {percentage_used}%";
            path = "/";
          };
        };
      };

      secondaryConfig = {
        secondaryTopBar = {
          output = [ bconfig.mine.waybar.secondaryMonitor "moonlight" ];
          layer = "top";
          position = "top";
          height = 48;
          margin = "0";

          modules-center = [ "hyprland/workspaces" ];

          "hyprland/workspaces" = {
            on-click = "activate";
            format = "{name}";
            active-only = false;
          };
        };

        secondaryBottomBar = {
          output = [ bconfig.mine.waybar.secondaryMonitor "moonlight" ];
          layer = "top";
          position = "bottom";
          height = 48;
          margin = "0";

          modules-center = [ "clock#date" ];
          modules-right = [ "memory" ];

          "clock#date" = {
            interval = 60;
            format = "{:%Y-%m-%d}";
          };
          memory = {
            interval = 30;
            format = "󰍛 {}%";
            max-length = 10;
          };
        };
      };
    in if bconfig.mine.waybar.secondaryMonitor != null then
      mainConfig // secondaryConfig
    else
      mainConfig;

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
      }

      window#waybar {
        background: transparent;
        border: none;
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
        background-color: @base01;
        color: @base05;
        border: 2px solid transparent;
      }

      #workspaces button.active {
        background-color: @base02;
        color: @base06;
        min-width: 32px;
        border: 2px solid @base02;
      }

      /* MODULES */
      #cpu,
      #memory,
      #clock,
      #disk,
      #custom-notification {
        border-radius: 7px;
        font-size: 14px;
        min-width: 60px;
        padding-left: 32px;
        padding-right: 32px;
        margin: 8px;
        background-color: @base01;
        color: @base05;
      }
    '';
  };
}
