{
  config,
  lib,
  ...
}: {
  options = {
    mine.sikarugir.enable = lib.mkEnableOption "Sikarugir (Kegworks/Whisky successor) for running Windows apps via Wine";
  };

  config = lib.mkIf config.mine.sikarugir.enable {
    homebrew.taps = ["Sikarugir-App/sikarugir"];
    homebrew.casks = ["Sikarugir-App/sikarugir/sikarugir"];
  };
}
