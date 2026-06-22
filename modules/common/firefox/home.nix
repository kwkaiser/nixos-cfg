{
  pkgs,
  lib,
  inputs,
  ...
}: {
  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";
    package = lib.mkIf pkgs.stdenv.isDarwin null; # Use Homebrew Firefox on macOS
    policies = {
      "3rdparty".Extensions."uBlock0@raymondhill.net" = {
        toAdd = {
          filterLists = [
            # Cookie notices
            "fanboy-cookiemonster"
            "ublock-cookies-easylist"
            "adguard-cookies"
            "ublock-cookies-adguard"

            # Social widgets
            "fanboy-social"
            "adguard-social"
            "fanboy-thirdparty_social"

            # Annoyances
            "easylist-annoyances"
            "easylist-chat"
            "easylist-newsletters"
            "easylist-notifications"
            "fanboy-ai-suggestions"
            "ublock-annoyances"
          ];
        };
      };
    };
    profiles = {
      kwkaiser = {
        extensions.force = true;
        extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
          ublock-origin
          keepassxc-browser
          sponsorblock
          zotero-connector
          consent-o-matic
          old-reddit-redirect
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

          # Always show bookmarks bar, including in fullscreen
          "browser.toolbars.bookmarks.visibility" = "always";
          "browser.fullscreen.autohide" = false;

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
