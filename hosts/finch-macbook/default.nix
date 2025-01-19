{ inputs, system, lib, ... }: {
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";
  system.stateVersion = 5;

  bingus.username = "kwkaiser";
  bingus.homeDir = "/Users/kwkaiser";
}
