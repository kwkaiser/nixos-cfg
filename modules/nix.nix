{ config, pkgs, isDarwin, lib, ... }:
{
  
} // (if isDarwin then { 
  nix = {
    distributedBuilds = true;
    linux-builder = {
      enable = true;
      ephemeral = true;
    };
    settings = {
      trusted-users = [ "@admin" "kwkaiser" "root" ];
      extra-trusted-users = [ "@admin" "kwkaiser" "root" ];
      experimental-features = [ "nix-command" "flakes" ];
    };
  };
} else
  { 
   nixpkgs.config.allowUnfree = true;
   nix.settings.experimental-features = [ "nix-command" "flakes" ];
  })
