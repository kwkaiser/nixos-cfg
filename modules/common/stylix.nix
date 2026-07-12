{
  pkgs,
  config,
  ...
}: {
  # joypixels (used below as the stylix emoji font) is unfree.
  nixpkgs.config.joypixels.acceptLicense = true;

  # Configure stylix in home-manager context to avoid conflicts
  home-manager.users.${config.mine.username} = {
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
}
