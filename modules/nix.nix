{ config, pkgs, isDarwin, ... }:
{
  
} // (if isDarwin then { 
  nix = {
    linux-builder = {
      enable = false;
      ephemeral = true;
      systems = [ "x86_64-linux" ];
    };
    settings = {
      trusted-users = [ "@admin" "kwkaiser" ];
      extra-trusted-users = [ "@admin" "kwkaiser" ];
      experimental-features = [ "nix-command" "flakes" ];
    };
  };
} else
  { 
   nixpkgs.config.allowUnfree = true;
   nix.settings.experimental-features = [ "nix-command" "flakes" ];
  })
