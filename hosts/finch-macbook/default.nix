{ inputs, system, lib, archi, ... }:
let
  commonArgs = {
    primaryUser = "kwkaiser";
    homeDir = "/Users/kwkaiser";
  };
in {
  nixpkgs.hostPlatform = lib.mkDefault archi;
  system.stateVersion = 5;

  # Define user
  users.users.${commonArgs.primaryUser} = {
    home = "${commonArgs.primaryUser}";
    description = "Primary user";
  };

  # Pass common args to home manager modules
  home-manager.extraSpecialArgs = { inherit inputs archi commonArgs; };
}
