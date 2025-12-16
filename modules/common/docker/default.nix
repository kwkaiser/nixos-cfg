{
  pkgs,
  config,
  lib,
  inputs,
  isDarwin,
  ...
}:
{
  options = {
    mine.docker.enable = lib.mkEnableOption "Whether or not to enable Docker";
  };

  config = lib.mkIf config.mine.docker.enable (
    lib.mkMerge [
      {
        home-manager.users.${config.mine.username} = {
          imports = [ ./home.nix ];
        };
      }
      (lib.mkIf (!isDarwin) {
        virtualisation.docker = {
          enable = true;
        };
        users.users.${config.mine.username}.extraGroups = [ "docker" ];
      })
    ]
  );
}
