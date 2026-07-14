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
      settings = {
        # KMS capture only sees real DRM connectors, so it can't see the
        # headless "moonlight" output - Sunshine's auto-detection then falls
        # through to the XDG portal, which xdg-desktop-portal-hyprland
        # doesn't implement RemoteDesktop for. wlr-screencopy works against
        # any wlr_output (headless or real), so force it for both.
        capture = "wlr";
      };
    };
  };
}
