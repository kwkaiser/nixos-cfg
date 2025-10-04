{ pkgs, lib, config, ... }: {
  imports = [
    ./kitty
    ./nix
    ./git
    ./neovim
    ./node
    ./python
    ./zsh
    ./keepass
    ./syncthing
    ./firefox
    ./messaging
    ./cursor
    ./gtk
    ./steam
    ./spotify
    ./notes
    ./ssh
    ./virt
    ./docker
    ./stylix.nix
  ];
}
