{
  config,
  mkDarwinSystem,
  ...
}: {
  flake.darwinConfigurations."work-macbook" = mkDarwinSystem (
    {lib, ...}: {
      imports = with config.darwin.modules; [
        identity
        base
        git
        nix-settings
        stylix
        python

        aero
        neovim
        kitty
        firefox
        zsh
        keepass
        node
        work
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
      mine.email = "kkaiser@lila.ai";
      mine.flakeHost = "work-macbook";
      mine.git.signCommits = true;
      mine.builder.enable = false;
      mine.git.signingKey = "RD6eqflf19EJJRF4Hj0NlpBq5Pzz9x7sq4mBe36lya8";
      mine.syncthing.deviceName = "work-macbook";
      mine.ssh.server.enable = false;
      mine.docker.backend = "colima";

      documentation.doc.enable = false;
      system.tools.darwin-uninstaller.enable = false;

      homebrew.enable = true;
    }
  );
}
