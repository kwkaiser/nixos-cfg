{pkgs, ...}: {
  home.packages = with pkgs; [
    typst
    poppler-utils

    lato
    font-awesome
  ];
}
