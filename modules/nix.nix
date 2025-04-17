{ config, pkgs, isDarwin, ... }:
{
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
} // (if isDarwin then {
  nix = {
    linux-builder = {
      enable = true;
      ephemeral = true;
      systems = [ "x86_64-linux" ];
    };
    settings = {
      trusted-users = [ "@admin" "kwkaiser" ];
      extra-trusted-users = [ "@admin" "kwkaiser" ];
    };
  };
} else
  { })
