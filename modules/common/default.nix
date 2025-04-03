{ pkgs, lib, config, ... }: {
  imports = [
    ./kitty
    ./git
    ./neovim
    ./node
    ./zsh
    ./keepass
    ./syncthing
    ./firefox
    ./messaging
    ./cursor
    ./steam
    ./notes
  ];
}
