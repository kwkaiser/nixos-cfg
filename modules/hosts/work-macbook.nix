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

      mine.aero.displayLayout = let
        leftPortraitDell = "57D33AAE-DAF8-4556-9ED5-86FDCE8F28B7";
        middleLandscapeDell = "FF43FD1C-0F60-4A49-9189-78928056144B";
        builtIn = "37D8832A-2D66-02CA-B9F7-8F30A301B230";
      in [
        "id:${leftPortraitDell} res:1200x1920 hz:60 color_depth:8 enabled:true scaling:off origin:(-3120,-1200) degree:270"
        "id:${middleLandscapeDell} res:1920x1200 hz:60 color_depth:8 enabled:true scaling:off origin:(-1920,-1200) degree:0"
        "id:${builtIn} res:1512x982 hz:120 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0"
      ];

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
