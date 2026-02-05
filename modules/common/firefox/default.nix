{ pkgs, config, lib, inputs, isDarwin, ... }: {
  options = {
    mine.firefox.enable = lib.mkEnableOption "Whether or not to use firefox";
  };

  config = lib.mkIf config.mine.firefox.enable ({
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  } // lib.optionalAttrs isDarwin { homebrew.casks = [ "firefox" ]; });
}
