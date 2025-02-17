{ pkgs, config, lib, inputs, ... }: {
  options = {
    mine.cursor.enable =
      lib.mkEnableOption "Whether or not to use cursor editor";
  };

  config = lib.mkIf config.mine.cursor.enable {
    homebrew = {
      enable = true;
      onActivation = { autoUpdate = true; };
      brews = [ ];
      casks = [ "cursor" ];
      taps = [ ];
    };

    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
