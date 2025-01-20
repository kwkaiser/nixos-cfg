{ pkgs, config, lib, inputs, ... }: {
  options = {
    mine.desktop.tiling.enable =
      lib.mkEnableOption "Whether or not to use aerospace shell";
  };

  config = lib.mkIf config.mine.desktop.tiling.enable {
    services.aerospace.enable = true;
    services.aerospace.settings = {
      gaps = {
        outer.left = 8;
        outer.bottom = 8;
        outer.top = 8;
        outer.right = 8;
      };
      mode.main.binding = {
        alt-h = "focus left";
        alt-j = "focus down";
        alt-k = "focus up";
        alt-l = "focus right";
      };
    };
  };
}
