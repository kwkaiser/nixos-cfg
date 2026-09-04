{
  config,
  mkDarwinSystem,
  lib,
  ...
}: {
  flake.darwinConfigurations."work-macbook" = mkDarwinSystem ({lib, ...}: {
    imports = with config.darwin.modules; [
      identity
      base
      git
      nix-settings
      stylix

      aero
      node
      neovim
      kitty
      firefox
      zsh
      keepass
      secretspec
      syncthing
      cursor
      steam
      notes
      messaging
      ssh
      virt
      docker
      work
      claude
      misc-cli-util
      tmux
      mc
      homelab-hosts-file
      gh-dash
      rust
      flyio
      codex
      firebase
      typst
      wireguard
      sikarugir
      borgmatic
    ];

    nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";
    system.stateVersion = 5;

    mine.git.signCommits = true;
    mine.syncthing.deviceName = "pallet-macbook";
    mine.ssh.server.enable = false;

    documentation.doc.enable = false;
    system.tools.darwin-uninstaller.enable = false;

    homebrew.enable = true;
  });
}
