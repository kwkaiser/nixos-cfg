{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.mine.tf2;

  rayshud = pkgs.fetchFromGitHub {
    owner = "raysfire";
    repo = "rayshud";
    rev = "2026.0111";
    hash = "sha256-bPo7Gwzj3tGEnw1kHoPg56wjrud5aj6Tcn3oGtc6fiU=";
  };

  bubbleHitsound = pkgs.runCommand "bubble-hitsound" {
    src = pkgs.fetchurl {
      url = "https://gamebanana.com/dl/185271";
      hash = "sha256-03EZFeIj006aAofn98LnQGaqzmxf4Aa02EseUe6Da7E=";
    };
    nativeBuildInputs = [pkgs.unar];
  } ''
    unar -o "$TMPDIR" "$src"
    mkdir -p "$out/sound/ui"
    cp "$TMPDIR/sound/ui/hitsound.wav" "$out/sound/ui/hitsound.wav"
  '';
in {
  options.mine.tf2 = {
    enable = lib.mkEnableOption "TF2 customizations";
    customPath = lib.mkOption {
      type = lib.types.str;
      description = "Absolute path to the TF2 tf/custom directory";
      example = "/home/user/data/steam/steamapps/common/Team Fortress 2/tf/custom";
    };
    rayshud.enable = lib.mkEnableOption "rayshud HUD";
    hitsound.enable = lib.mkEnableOption "bubble hitsound";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${config.mine.username} = {
      home.activation.tf2 = {
        after = ["writeBoundary"];
        before = [];
        data = ''
          ${lib.optionalString cfg.rayshud.enable ''
            dst="${cfg.customPath}/rayshud"
            [ -L "$dst" ] && $DRY_RUN_CMD rm "$dst"
            $DRY_RUN_CMD ln -sf "${rayshud}" "$dst"
          ''}
          ${lib.optionalString cfg.hitsound.enable ''
            dst="${cfg.customPath}/nix-hitsound"
            [ -L "$dst" ] && $DRY_RUN_CMD rm "$dst"
            $DRY_RUN_CMD ln -sf "${bubbleHitsound}" "$dst"
          ''}
        '';
      };
    };
  };
}
