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

    style = ''
      * {
        font-size: 11px;
      }

      window#waybar {
        background: transparent;
      }

      /* WORKSPACE */

      #workspaces button {
        background: #${config.colorScheme.palette.base00}; /* base00 for background */
        color: #${config.colorScheme.palette.base05}; /* base05 for text */
        min-width: 8px;
        padding-left: 16px;
        padding-right: 16px;
        padding-top: 6px;
        padding-bottom: 6px;
        margin-top: 8px;
        margin-left: 4px;
        margin-right: 4px;
        border: 1px solid #${config.colorScheme.palette.base03}; /* base03 for subtle border */
        border-radius: 7px;
      }

      #workspaces button.focused {
        color: #${config.colorScheme.palette.base07}; /* base07 for focused text */
        background: #${config.colorScheme.palette.base00}; /* base00 for background */
        border: 1px solid #${config.colorScheme.palette.base02}; /* base02 for focused border */
      }

      #workspaces button.urgent {
        color: #${config.colorScheme.palette.base07}; /* base07 for urgent text */
        background: #${config.colorScheme.palette.base00}; /* base00 for background */
        border: 1px solid #${config.colorScheme.palette.base08}; /* base08 for urgent border */
      }

      /* SYS STATS */

      #cpu,
      #memory,
      #clock,
      #disk,
      #network {
        color: #${config.colorScheme.palette.base0E}; /* base0E for accent text */
        background: #${config.colorScheme.palette.base00}; /* base00 for background */
        border: 1px solid #${config.colorScheme.palette.base02}; /* base02 for border */
        border-radius: 7px;
        font-size: 14px;
        min-width: 60px;
        padding-left: 32px;
        padding-right: 32px;
        margin-bottom: 8px;
        margin-left: 8px;
        margin-right: 8px;
      }

      #network {
        padding-left: 6px;
        padding-right: 6px;
      }
    '';
  };
}
