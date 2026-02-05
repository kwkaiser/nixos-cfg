{
  config,
  pkgs,
  lib,
  bconfig,
  isDarwin,
  ...
}:
{
  home.packages = with pkgs; [
    zoxide
  ];
}
