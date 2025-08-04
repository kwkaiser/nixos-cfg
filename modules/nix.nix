{ config, pkgs, isDarwin, lib, ... }:
{
  
} // (if isDarwin then { 
  nix = {
    distributedBuilds = true;
    settings = {
      trusted-users = [ "@admin" "kwkaiser" "root" ];
      extra-trusted-users = [ "@admin" "kwkaiser" "root" ];
      experimental-features = [ "nix-command" "flakes" ];
      builders = lib.mkForce [
        "ssh-ng://desktop x86_64-linux - 4 1"
      ];
      builders-use-substitutes = true;
    };
  };
} else
  { 
   nixpkgs.config.allowUnfree = true;
   nix.settings.experimental-features = [ "nix-command" "flakes" ];
  })
