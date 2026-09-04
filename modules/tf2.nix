{ mkModuleOption, ... }:
let
  hmModule =
    {
      config,
      lib,
      pkgs,
      osConfig,
      ...
    }:
    let
      cfg = osConfig.mine.tf2;

      rayshud = pkgs.fetchFromGitHub {
        owner = "raysfire";
        repo = "rayshud";
        rev = "2026.0111";
        hash = "sha256-bPo7Gwzj3tGEnw1kHoPg56wjrud5aj6Tcn3oGtc6fiU=";
      };

      bubbleHitsound =
        pkgs.runCommand "bubble-hitsound"
          {
            src = pkgs.fetchurl {
              url = "https://gamebanana.com/dl/185271";
              hash = "sha256-03EZFeIj006aAofn98LnQGaqzmxf4Aa02EseUe6Da7E=";
            };
            nativeBuildInputs = [ pkgs.unar ];
          }
          ''
            unar -o "$TMPDIR" "$src"
            mkdir -p "$out/sound/ui"
            cp "$TMPDIR"/*/sound/ui/hitsound.wav "$out/sound/ui/hitsound.wav"
          '';
    in
    {
      home.activation.tf2 = {
        after = [ "writeBoundary" ];
        before = [ ];
        data = ''
          ${lib.optionalString cfg.rayshud.enable ''
            dst="${cfg.customPath}/rayshud"
            if [ -d "${cfg.customPath}" ]; then
              [ -L "$dst" ] && $DRY_RUN_CMD rm "$dst"
              $DRY_RUN_CMD ln -sf "${rayshud}" "$dst"
            fi
          ''}
          ${lib.optionalString cfg.hitsound.enable ''
            dst="${cfg.customPath}/nix-hitsound"
            if [ -d "${cfg.customPath}" ]; then
              [ -L "$dst" ] && $DRY_RUN_CMD rm "$dst"
              $DRY_RUN_CMD ln -sf "${bubbleHitsound}" "$dst"
            fi
          ''}
        '';
      };
    };

  featureOptions = { lib, ... }: {
    options.mine.tf2 = {
      customPath = lib.mkOption {
        type = lib.types.str;
        description = "Absolute path to the TF2 tf/custom directory";
        example = "/home/user/data/steam/steamapps/common/Team Fortress 2/tf/custom";
      };
      rayshud.enable = lib.mkEnableOption "rayshud HUD";
      hitsound.enable = lib.mkEnableOption "bubble hitsound";
    };
  };
in
{
  # nixos-only: TF2 is only played on desktop, a nixos host.
  options.nixos.modules.tf2 = mkModuleOption { };

  config.nixos.modules.tf2 = { config, ... }: {
    imports = [ featureOptions ];
    home-manager.users.${config.mine.username}.imports = [ hmModule ];
  };
}
