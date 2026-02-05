{
  config,
  pkgs,
  lib,
  bconfig,
  isDarwin,
  ...
}:
{
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
