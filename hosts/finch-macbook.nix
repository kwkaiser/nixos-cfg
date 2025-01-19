{ inputs, system, lib, ... }: {
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";
  system.stateVersion = 5;

  mine.username = "kwkaiser";
  mine.homeDir = "/Users/kwkaiser";
  mine.shell.zsh.enabled = true;
}
