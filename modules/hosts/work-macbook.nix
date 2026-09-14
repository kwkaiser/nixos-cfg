{
  config,
  mkDarwinSystem,
  lib,
  ...
}: {
  flake.darwinConfigurations."work-macbook" = mkDarwinSystem (
    {lib, ...}: {
      imports = with config.darwin.modules; [
        identity
        base
        git
        nix-settings
        macos-minimal
        stylix

        aero
        neovim
        kitty
        firefox
        zsh
        keepass
        secretspec
        syncthing
        ssh
        docker
        claude
        misc-cli-util
        tmux
        gh-dash
        rust
        tailcat
      ];

      nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";
      system.stateVersion = 5;

      mine.username = "kkaiser";
      mine.flakeHost = "work-macbook";
      mine.git.signCommits = true;
      mine.syncthing.deviceName = "work-macbook";
      mine.ssh.server.enable = false;

      documentation.doc.enable = false;
      system.tools.darwin-uninstaller.enable = false;

      homebrew.enable = true;
    }
  );
}
