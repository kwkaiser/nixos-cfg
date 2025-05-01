{ pkgs, lib, config, inputs, home, bconfig, ... }: {
  home.packages = with pkgs; [ libnotify ];
  services.swaync = {
    enable = true;
    settings = {
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      control-center-layer = "top";
      layer-shell = true;
      cssPriority = "application";
      control-center-margin-top = 0;
      control-center-margin-bottom = 0;
      control-center-margin-right = 0;
      control-center-margin-left = 0;
      notification-2fa-action = true;
      notification-inline-replies = false;
      notification-icon-size = 64;
      notification-body-image-height = 100;
      notification-body-image-width = 200;
      hide-on-clear = true;
      hide-on-action = true;
      widgets = [ "title" "notifications" "dnd" "volume" ];
      popup = {
        enabled = false;
        timeout = 0;
      };
    };
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
      }

      .notification-row {
        outline: none;
      }

      .notification {
        background: @base00;
        border-radius: 8px;
        margin: 6px;
        box-shadow: 0 0 8px 0 rgba(0, 0, 0, 0.2);
        border: 2px solid @base01;
      }

      .notification-content {
        background: transparent;
        padding: 6px;
        color: @base05;
      }

      .notification.critical {
        border: 2px solid @base08;
      }

      .notification.low {
        border: 2px solid @base0B;
      }

      .control-center {
        background: @base00;
        border-radius: 8px;
        border: 2px solid @base01;
        margin: 8px;
        padding: 8px;
        box-shadow: 0 0 8px 0 rgba(0, 0, 0, 0.2);
      }
    '';
  };
}
