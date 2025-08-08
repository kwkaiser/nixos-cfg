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
    ./gtk
    ./steam
    ./notes
    ./ssh
    ./virt
    ./docker
    ./stylix.nix
  ];
}
