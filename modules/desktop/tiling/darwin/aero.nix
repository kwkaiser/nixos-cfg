{ pkgs, config, lib, inputs, ... }: {
  options = {
    mine.desktop.tiling.enable =
      lib.mkEnableOption "Whether or not to use aerospace shell";
  };

  config = lib.mkIf config.mine.desktop.tiling.enable {
    services.aerospace.enable = true;
    system.defaults.dock.autohide = true;
    services.aerospace.settings = {
      mode.main.binding = {
        cmd-h = "focus left";
        cmd-j = "focus down";
        cmd-k = "focus up";
        cmd-l = "focus right";
        cmd-shift-h = "move left";
        cmd-shift-j = "move down";
        cmd-shift-k = "move up";
        cmd-shift-l = "move right";
        cmd-shift-f = "layout floating tiling";
        cmd-shift-b = "layout tiling";
        cmd-slash = "layout v_tiles";
        cmd-backslash = "layout h_tiles";
        cmd-1 = "workspace 1";
        cmd-2 = "workspace 2";
        cmd-3 = "workspace 3";
        cmd-4 = "workspace 4";
        cmd-5 = "workspace 5";
        cmd-6 = "workspace 6";
        cmd-7 = "workspace 7";
        cmd-8 = "workspace 8";
        cmd-9 = "workspace 9";
        cmd-0 = "workspace 10";
        cmd-shift-1 = "move-node-to-workspace 1";
        cmd-shift-2 = "move-node-to-workspace 2";
        cmd-shift-3 = "move-node-to-workspace 3";
        cmd-shift-4 = "move-node-to-workspace 4";
        cmd-shift-5 = "move-node-to-workspace 5";
        cmd-shift-6 = "move-node-to-workspace 6";
        cmd-shift-7 = "move-node-to-workspace 7";
        cmd-shift-8 = "move-node-to-workspace 8";
        cmd-shift-9 = "move-node-to-workspace 9";
      };
    };

  };
}
