{ pkgs, config, lib, inputs, ... }: {
  stylix.enable = true;
  stylix.image = ../../assets/backgrounds/cherry.jpg;
  stylix.base16Scheme =
    "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
}
