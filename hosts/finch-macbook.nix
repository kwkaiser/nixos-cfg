{ inputs, system, lib, ... }: {
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";
  system.stateVersion = 5;

  mine.username = "kwkaiser";
  mine.homeDir = "/Users/kwkaiser";
  mine.email = "karl@kwkaiser.io";
  mine.desktop.tiling.enable = true;
  mine.git.signsCommits = true;
  mine.dev.node.enable = true;
  mine.dev.editor.neovim.enable = true;
}
