{
  lib,
  config,
  ...
}: {
  options = {
    mine.pathofbuilding.enable = lib.mkEnableOption "Enables Path of Building (offline PoE build planner)";
  };

  config = lib.mkIf config.mine.pathofbuilding.enable {
    home-manager.users.${config.mine.username} = {imports = [./home.nix];};
  };
}
