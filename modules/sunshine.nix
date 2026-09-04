{ mkModuleOption, ... }:
{
  options.nixos.modules.sunshine = mkModuleOption { };

  config.nixos.modules.sunshine = {
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
