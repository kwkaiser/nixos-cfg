{ config, pkgs, isDarwin, lib, ... }:
{
  # Global nixpkgs configuration for all systems
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = _: true;
  environment.systemPackages = with pkgs; [ nixfmt-rfc-style ];
  home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };

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
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 3d";
      persistent = true;
    };
    optimise = {
      automatic = true;
      persistent = true;
    };
    settings = { experimental-features = [ "nix-command" "flakes" ]; };
  };
})
