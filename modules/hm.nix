{ config, pkgs, ... }:

{
  home.stateVersion = "24.11";
  nixpkgs.config.allowUnfree = true;
}
