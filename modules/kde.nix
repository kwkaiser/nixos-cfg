{ mkModuleOption, ... }:
let
  hmModule =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      services.kdeconnect = {
        enable = true;
        indicator = true;
      };

      home.packages = with pkgs; [
        kde-rounded-corners
        kdePackages.krohnkite
        kdotool
      ];

      programs.plasma = {
        enable = true;

        input = {
          keyboard = {
            layouts = [ { layout = "us"; } ];
            repeatDelay = 250;
            repeatRate = 40;
          };
        };

        krunner.activateWhenTypingOnDesktop = false;

        kwin = {
          nightLight = {
            enable = true;
            location.latitude = "42.35";
            location.longitude = "71.05";
            mode = "location";
            temperature.night = 3600;
          };

          virtualDesktops = {
            number = 10;
            rows = 1;
          };
        };

        overrideConfig = true;

        session = {
          general.askForConfirmationOnLogout = false;
          sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";
        };

        shortcuts = {
          "KDE Keyboard Layout Switcher" = {
            "Switch to Next Keyboard Layout" = "Meta+Space";
          };

          kwin = {
            "KrohnkiteMonocleLayout" = [ ];
            "Overview" = "Meta+A";
            "Switch to Desktop 1" = "Meta+1";
            "Switch to Desktop 2" = "Meta+2";
            "Switch to Desktop 3" = "Meta+3";
            "Switch to Desktop 4" = "Meta+4";
            "Switch to Desktop 5" = "Meta+5";
            "Switch to Desktop 6" = "Meta+6";
            "Switch to Desktop 7" = "Meta+7";
            "Switch to Desktop 8" = "Meta+8";
            "Switch to Desktop 9" = "Meta+9";
            "Switch to Desktop 10" = "Meta+0";
            "Window Close" = "Meta+Q";
            "Window Fullscreen" = "Meta+M";
            "Window Move Center" = "Ctrl+Alt+C";
            "Window to Desktop 1" = "Meta+!";
            "Window to Desktop 2" = "Meta+@";
            "Window to Desktop 3" = "Meta+#";
            "Window to Desktop 4" = "Meta+$";
            "Window to Desktop 5" = "Meta+%";
            "Window to Desktop 6" = "Meta+^";
            "Window to Desktop 7" = "Meta+&";
            "Window to Desktop 8" = "Meta+*";
            "Window to Desktop 9" = "Meta+(";
            "Window to Desktop 10" = "Meta+)";
          };

          plasmashell = {
            "show-on-mouse-pos" = "";
          };

          "services/org.kde.dolphin.desktop"."_launch" = "Meta+Shift+F";
        };

        spectacle = {
          shortcuts = {
            captureEntireDesktop = "";
            captureRectangularRegion = "";
            launch = "";
            recordRegion = "Meta+Shift+R";
            recordScreen = "Meta+Ctrl+R";
            recordWindow = "";
          };
        };

        workspace = {
          enableMiddleClickPaste = false;
          clickItemTo = "select";
          splashScreen.engine = "none";
          splashScreen.theme = "none";
          tooltipDelay = 1;
        };

        configFile = {
          baloofilerc."Basic Settings"."Indexing-Enabled" = false;
          kdeglobals = {
            KDE = {
              AnimationDurationFactor = 0;
            };
          };
          klaunchrc.FeedbackStyle.BusyCursor = false;
          klipperrc.General.MaxClipItems = 1000;
          kwinrc = {
            Effect-overview.BorderActivate = 9;
            Plugins = {
              krohnkiteEnabled = true;
              screenedgeEnabled = false;
            };
            "Round-Corners" = {
              ActiveOutlineAlpha = 255;
              ActiveOutlineUseCustom = false;
              ActiveOutlineUsePalette = true;
              ActiveSecondOutlineUseCustom = false;
              ActiveSecondOutlineUsePalette = true;
              DisableOutlineTile = false;
              DisableRoundTile = false;
              InactiveCornerRadius = 8;
              InactiveOutlineAlpha = 0;
              InactiveOutlineUseCustom = false;
              InactiveOutlineUsePalette = true;
              InactiveSecondOutlineAlpha = 0;
              InactiveSecondOutlineThickness = 0;
              OutlineThickness = 1;
              SecondOutlineThickness = 0;
              Size = 8;
            };
            "Script-krohnkite" = {
              floatingClass = "ulauncher,brave-nngceckbapebfimnlniiiahkandclblb-Default,org.kde.kcalc";
              screenGapBetween = 3;
              screenGapBottom = 3;
              screenGapLeft = 3;
              screenGapRight = 3;
              screenGapTop = 3;
            };
            Windows = {
              DelayFocusInterval = 0;
              FocusPolicy = "FocusFollowsMouse";
            };
          };
          plasmanotifyrc = {
            DoNotDisturb.WhenScreenSharing = false;
            Notifications.PopupTimeout = 7000;
          };
          plasmarc.OSD.Enabled = false;
          spectaclerc = {
            Annotations.annotationToolType = 8;
            General = {
              launchAction = "DoNotTakeScreenshot";
              showCaptureInstructions = false;
              showMagnifier = "ShowMagnifierAlways";
              useReleaseToCapture = true;
            };
            ImageSave.imageCompressionQuality = 100;
          };
        };
      };
    };
in
{
  options.nixos.modules.kde = mkModuleOption { };

  config.nixos.modules.kde = { config, ... }: {
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

    home-manager.users.${config.mine.username}.imports = [ hmModule ];
  };
}
