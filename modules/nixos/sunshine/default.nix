{ pkgs, config, lib, ... }: {
  options = {
    mine.sunshine.enable =
      lib.mkEnableOption "Whether or not to enable sunshine";
  };

  config = lib.mkIf config.mine.sunshine.enable {
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
    };
  };
}
