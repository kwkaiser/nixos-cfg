{
  config,
  lib,
  isDarwin,
  ...
}: {
  options = {
    mine.work.enable = lib.mkEnableOption "Grab bag for misc work scripts / setup stuff";
  };

  config = lib.mkIf config.mine.work.enable ({
      home-manager.users.${config.mine.username} = {
        imports = [./home.nix];
      };
    }
    // lib.optionalAttrs isDarwin {
      homebrew.taps = ["schpet/tap"];
      homebrew.brews = ["schpet/tap/linear"];
      homebrew.casks = ["linear-linear"];
    });
}
