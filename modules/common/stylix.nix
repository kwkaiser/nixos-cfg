{ pkgs, config, lib, inputs, ... }: {
  # Configure stylix in home-manager context to avoid conflicts
  home-manager.users.${config.mine.username} = {
    stylix.enable = true;
    stylix.image = ../../assets/backgrounds/bay-wharf.jpg;
    # Other themes available under https://github.com/tinted-theming/base16-schemes
    stylix.base16Scheme =
      "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    stylix.targets.firefox.profileNames = [ "kwkaiser" ];
  };
}
