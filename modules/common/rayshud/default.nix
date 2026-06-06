{
  config,
  lib,
  pkgs,
  ...
}: let
  rayshud = pkgs.fetchFromGitHub {
    owner = "raysfire";
    repo = "rayshud";
    rev = "2026.0111";
    hash = "sha256-bPo7Gwzj3tGEnw1kHoPg56wjrud5aj6Tcn3oGtc6fiU=";
  };
in {
  options.mine.rayshud = {
    enable = lib.mkEnableOption "rayshud TF2 HUD";
    customPath = lib.mkOption {
      type = lib.types.str;
      description = "Absolute path to the TF2 tf/custom directory where rayshud will be symlinked";
      example = "/home/user/data/steam/steamapps/common/Team Fortress 2/tf/custom";
    };
  };

  config = lib.mkIf config.mine.rayshud.enable {
    home-manager.users.${config.mine.username} = {
      home.activation.rayshud = lib.hm.dag.entryAfter ["writeBoundary"] ''
        dst="${config.mine.rayshud.customPath}/rayshud"
        [ -L "$dst" ] && $DRY_RUN_CMD rm "$dst"
        $DRY_RUN_CMD ln -sf "${rayshud}" "$dst"
      '';
    };
  };
}
