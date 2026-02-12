{
  pkgs,
  lib,
  inputs,
  ...
}: {
  programs.firefox = {
    enable = true;
    package = lib.mkIf pkgs.stdenv.isDarwin null; # Use Homebrew Firefox on macOS
    profiles = {
      kwkaiser = {
        extensions.force = true;
        extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
          ublock-origin
          keepassxc-browser
          i-dont-care-about-cookies
          sponsorblock
          zotero-connector
        ];

        # Smooth scrolling preferences
        settings = {
          # Enable smooth scrolling
          "general.smoothScroll" = true;
          "general.smoothScroll.pages" = true;
          "general.smoothScroll.mouseWheel" = true;
          "general.smoothScroll.scrollbars" = true;

          # Reduce mouse wheel scroll distance for finer control
          "mousewheel.min_line_scroll_amount" = 1;

          # Adjust mouse wheel acceleration for smoother feel
          "mousewheel.acceleration.factor" = 3;
          "mousewheel.acceleration.start" = 2;

          # Use system scroll settings when possible
          "mousewheel.system_scroll_override_on_root_content.enabled" = false;

          # Reduce scroll jump distance
          "toolkit.scrollbox.smoothScroll" = true;
          "toolkit.scrollbox.verticalScrollDistance" = 3;
          "toolkit.scrollbox.horizontalScrollDistance" = 5;

          # Additional smooth scrolling tweaks
          "mousewheel.default.delta_multiplier_x" = 100;
          "mousewheel.default.delta_multiplier_y" = 100;
          "mousewheel.default.delta_multiplier_z" = 100;

          # Privacy settings - preserve cookies and site data when Firefox closes
          "privacy.sanitize.sanitizeOnShutdown" = false;
          "privacy.clearOnShutdown.cache" = false;
          "privacy.clearOnShutdown.cookies" = false;
          "privacy.clearOnShutdown.downloads" = false;
          "privacy.clearOnShutdown.formdata" = false;
          "privacy.clearOnShutdown.history" = false;
          "privacy.clearOnShutdown.sessions" = false;
          "privacy.clearOnShutdown.siteSettings" = false;
          "privacy.clearOnShutdown.offlineApps" = false;
        };
      };
    };
  };
}
