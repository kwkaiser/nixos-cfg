{ config, pkgs, ... }: {
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };
    brews = [ ];
    casks = [ "cursor" ];
    taps = [ ];
  };
}
