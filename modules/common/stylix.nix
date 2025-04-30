{ pkgs, config, lib, inputs, ... }: {
  stylix.enable = true;
  stylix.image = ../../assets/backgrounds/cherry.jpg;
  # Other themes available under https://github.com/tinted-theming/base16-schemes
  stylix.base16Scheme =
    "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
}
