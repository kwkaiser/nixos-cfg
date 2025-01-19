{ inputs, system, lib, archi, commonArgs, ... }: {
  nixpkgs.hostPlatform = lib.mkDefault archi;
  system.stateVersion = 5;

  # Define user
  users.users.${commonArgs.primaryUser} = {
    home = builtins.toPath "${commonArgs.homeDir}";
    description = "Primary user";
  };

  # Pass common args to home manager modules
  home-manager.extraSpecialArgs = { inherit inputs archi commonArgs; };

  foo.alacritty.enabled = true;
}
