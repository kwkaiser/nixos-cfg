{ pkgs, lib, config, inputs, home, bconfig, ... }: {
  # KDE Plasma specific packages
  home.packages = with pkgs; [
    # KDE applications
    kdePackages.konsole
    kdePackages.dolphin
    kdePackages.kate
    kdePackages.gwenview
    kdePackages.okular

    # Additional useful applications
    firefox
    kitty
  ];

  # KDE Plasma configuration
  programs.plasma = {
    enable = true;

    # Configure KDE settings
    configFile = {
      "kglobalshortcutsrc" = {
        "kwin"."KDE Keyboard Layout Switcher"."Meta+Alt+K" = "none";
        "kwin"."KDE Keyboard Layout Switcher"."Meta+Alt+K,None" = "none";
      };
    };
  };

  # Configure KDE applications
  programs.konsole = {
    enable = true;
    defaultProfile = "Default";
    profiles = {
      Default = {
        name = "Default";
        command = "zsh";
        colorScheme = "Breeze";
        font = {
          family = "JetBrainsMono Nerd Font";
          size = 12;
        };
      };
    };
  };

  # Configure Dolphin file manager
  programs.dolphin = {
    enable = true;
    settings = {
      General = {
        ShowFullPath = true;
        ShowSpaceInfo = true;
      };
      DetailsMode = { PreviewSize = 32; };
    };
  };

  # Configure Kate text editor
  programs.kate = {
    enable = true;
    settings = {
      "General"."Show Full Path in Title" = true;
      "General"."Show Path in Title" = true;
    };
  };

  # Configure KDE notifications
  services.kdeconnect = {
    enable = true;
    indicator = true;
  };
}
