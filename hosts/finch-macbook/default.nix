{ inputs, system, lib, archi, ... }: {
  nixpkgs.hostPlatform = lib.mkDefault archi;
  system.stateVersion = 5;

  bingus.username = "kwkaiser";
  bingus.homeDir = "/Users/kwkaiser";
}
