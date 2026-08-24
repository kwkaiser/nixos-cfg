{
  pkgs,
  config,
  lib,
  isDarwin,
  ...
}: {
  options.mine.stylix.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Whether to apply stylix theming (fonts, wallpaper, GTK/dconf theme) to the primary user. Disable on headless hosts with no desktop session - dconf activation fails without one.";
  };

  config = lib.mkIf config.mine.stylix.enable {
    # joypixels (used below as the stylix emoji font) is unfree.
    nixpkgs.config.joypixels.acceptLicense = true;

    # Configure stylix in home-manager context to avoid conflicts
    home-manager.users.${config.mine.username} = {
      dconf.enable =
        lib.mkDefault (!isDarwin && (config.mine.hyprland.enable || config.mine.kde.enable));

      stylix.enable = true;
      stylix.image = ../../assets/backgrounds/bay-wharf.jpg;
      # Other themes available under https://github.com/tinted-theming/base16-schemes
      stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
      stylix.targets.firefox.profileNames = ["kwkaiser"];
      stylix.targets.firefox.colorTheme.enable = true;
      stylix.targets.nvf.enable = false; # Managed by nvf theme instead
      stylix.fonts.emoji = {
        package = pkgs.joypixels;
        name = "JoyPixels";
      };
      stylix.fonts.monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
    };
  };
}
