{pkgs, ...}: {
  home.packages = with pkgs; [
    nodejs_24
    nodenv
    pango
    cairo
    pixman
    fontconfig
    pnpm
  ];
}
