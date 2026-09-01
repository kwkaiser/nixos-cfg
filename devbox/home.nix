{ inputs, ... }:
{
  imports = [
    inputs.nvf.homeManagerModules.default
    ../modules/common/ssh/home.nix
    ../modules/common/neovim/home.nix
    ../modules/common/git/home.nix
    ../modules/common/tmux/home.nix
    ../modules/common/node/home.nix
  ];

  home.username = "root";
  home.homeDirectory = "/root";
  home.stateVersion = "25.05";
}
