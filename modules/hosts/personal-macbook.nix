{mkDarwinSystem, ...} @ topArgs: {
  flake.darwinConfigurations."personal-macbook" = mkDarwinSystem (
    {
      lib,
      config,
      ...
    }: {
      imports = with topArgs.config.darwin.modules; [
        identity
        base
        git
        nix-settings
        stylix

        anki
        aero
        macos-minimal
        macos-snappy
        macos-perf
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
        tmt
        mc
        homelab-hosts-file
        gh-dash
        rust
        golang
        tailscale
        flyio
        codex
        firebase
        typst
        wireguard
        sikarugir
        borgmatic
        spotlight
        handy
        herdr
      ];

      nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";
      system.stateVersion = 5;

      networking.hostName = "personal-macbook";

      mine.username = "kwkaiser";
      mine.flakeHost = "personal-macbook";
      mine.git.signCommits = true;
      mine.syncthing.deviceName = "personal-macbook";
      mine.ssh.server.enable = false;

      documentation.doc.enable = false;
      system.tools.darwin-uninstaller.enable = false;

      homebrew.enable = true;
      homebrew.onActivation.cleanup = "zap";

      system.defaults.dock.persistent-apps = ["${config.mine.homeDir}/Applications/Home Manager Apps/Firefox.app"];

      home-manager.users.${config.mine.username}.mine.tmt.claudeCommand = "ccpm";
    }
  );
}
