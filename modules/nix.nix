{ config, pkgs, isDarwin, lib, ... }:
{
  # Global nixpkgs configuration for all systems
  nixpkgs.config.allowUnfree = true;
} // (if isDarwin then {
  nix = {
    distributedBuilds = true;
    linux-builder = {
      enable = true;
      ephemeral = true;
    };
    settings = {
      trusted-users = [ "@admin" "kwkaiser" "root" "karl" ];
      extra-trusted-users = [ "@admin" "kwkaiser" "root" "karl" ];
      experimental-features = [ "nix-command" "flakes" ];
    };
  };
} else {
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
})
