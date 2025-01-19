{ inputs, system, lib, archi, commonArgs, ... }: {
  nixpkgs.hostPlatform = lib.mkDefault archi;
  system.stateVersion = 5;

  bingus.username = "kwkaiser";
  bingus.homeDir = "/Users/kwkaiser";
}
