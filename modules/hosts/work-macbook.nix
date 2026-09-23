{
  mkDarwinSystem,
  ...
} @ topArgs: {
  flake.darwinConfigurations."work-macbook" = mkDarwinSystem (
    {
      lib,
      pkgs,
      config,
      ...
    }: {
      imports = with topArgs.config.darwin.modules; [
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

      home-manager.users.${config.mine.username}.mine.claude.extraMcpServers.grafana = {
        command = "${pkgs.mcp-grafana}/bin/mcp-grafana";
        env = {
          GRAFANA_URL = "\${GRAFANA_URL}";
          GRAFANA_SERVICE_ACCOUNT_TOKEN = "\${GRAFANA_SERVICE_ACCOUNT_TOKEN}";
        };
      };
    }
  );
}
