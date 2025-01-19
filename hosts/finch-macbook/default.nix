{ inputs, system, lib, archi, ... }: {
  nixpkgs.hostPlatform = lib.mkDefault archi;
  system.stateVersion = 5;

}
