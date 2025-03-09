{ pkgs, lib, config, ... }: {
  imports = [
    ./kitty
    ./git
    ./neovim
    ./node
    ./zsh
    ./keepass
    ./syncthing
    ./cursor
    ./steam
  ];
}
