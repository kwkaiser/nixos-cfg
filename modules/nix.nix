{ config, pkgs, isDarwin, ... }:
{
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
} // (if isDarwin then {
  nix = {
    linux-builder.enable = true;
    settings.trusted-users = [ "@admin" ];
  };

} else
  { })
