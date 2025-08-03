{ config, pkgs, isDarwin, lib, ... }:
{
  
} // (if isDarwin then { 
  nix = {
    settings = {
      trusted-users = [ "@admin" "kwkaiser" "root" ];
      extra-trusted-users = [ "@admin" "kwkaiser" "root" ];
      experimental-features = [ "nix-command" "flakes" ];
      builders = lib.mkForce [
        "ssh-ng://desktop x86_64-linux - 0"
      ];
    };
  };
} else
  { 
   nixpkgs.config.allowUnfree = true;
   nix.settings.experimental-features = [ "nix-command" "flakes" ];
  })
