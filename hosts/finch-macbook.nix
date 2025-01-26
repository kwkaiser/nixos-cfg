{ inputs, system, lib, ... }: {
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";
  system.stateVersion = 5;

  mine.username = "kwkaiser";
  mine.homeDir = "/Users/kwkaiser";
  mine.email = "karl@kwkaiser.io";

  mine.aero.enable = true;
  mine.git.signsCommits = true;
  mine.node.enable = true;
  mine.neovim.enable = true;
}
