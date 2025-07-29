{ pkgs, lib, config, ... }: {

  options = {
    mine.kde.enable =
      lib.mkEnableOption "Enables KDE Plasma desktop environment";
  };

  config = lib.mkIf config.mine.kde.enable {
    # Enable KDE Plasma 6
    services.xserver.enable = true;
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;

    # Enable sound with pipewire
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Home manager config
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}

