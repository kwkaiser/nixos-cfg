{ pkgs, lib, config, ... }: {
  imports = [ ./kitty ./git ./neovim ./node ./zsh ./cursor ./keepass ];
}
