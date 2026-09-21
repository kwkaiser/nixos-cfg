{mkModuleOption, ...}: let
  hmModule = {
    pkgs,
    config,
    lib,
    inputs,
    ...
  }: let
    devbox = inputs.nixpkgs-devbox.legacyPackages.${pkgs.stdenv.hostPlatform.system}.devbox;

    lila-auth-cli = pkgs.buildGoModule rec {
      pname = "lila-auth-cli";
      version = "0.6.0";
      src = inputs.lila-auth-cli;
      vendorHash = "sha256-bCLdNyDvSKl6c3VE3wwoeIuFs8QnNUfaNbjo5UB/1OY=";
      ldflags = [
        "-s"
        "-w"
        "-X github.com/lilasci-dev/lila-auth-cli/cmd.Version=${version}"
      ];
      postInstall = "mv $out/bin/${pname} $out/bin/lila-auth";
    };

    defaultTmuxinatorWindows = [
      {claude = "clear && ccp";}
      {editor = "clear";}
      {driver = "clear";}
    ];

    mkTmuxinatorProject = name: root: {
      inherit name root;
      windows = defaultTmuxinatorWindows;
    };

    mkLimsMcp = url: {
      type = "http";
      inherit url;
      oauth = {
        clientId = "mcp-servers";
        callbackPort = 8080;
      };
    };
  in {
    home.packages = with pkgs; [
      devbox
      lila-auth-cli
      gh
      gh-dash
      awscli2
      google-cloud-sdk
      typescript
      vtsls
      ssm-session-manager-plugin

      (writeShellScriptBin "work-init" ''
        tmuxinator start --no-attach primary
        tmuxinator start --no-attach wt-1
        tmuxinator start --no-attach wt-2
      '')
      (writeShellScriptBin "pccp" ''
        kitty --directory ~/Documents/pallet/copallet ccp &
        kitty --directory ~/Documents/pallet/copallet-wt-1 ccp &
        kitty --directory ~/Documents/pallet/copallet-wt-2 ccp &
      '')

      (writeShellScriptBin "bind-mermaid" ''
        host="''${1:?usage: bind-mermaid <ssh-host>}"
        exec ssh -N -L 3737:localhost:3737 -L 3738:localhost:3738 -L 3739:localhost:3739 "$host"
      '')
    ];

    mine.claude.extraMcpServers = {
      sentry = {
        type = "http";
        url = "https://mcp.sentry.dev/mcp";
      };

      lims-dev = mkLimsMcp "https://lims-mcp-dev.solo.lilasci.io/mcp";
      lims-staging = mkLimsMcp "https://lims-mcp-staging.ripley.lilasci.io/mcp";
      lims-prod = mkLimsMcp "https://lims-mcp-prod.ride.lilasci.io/mcp";
    };

    # Tmuxinator project configs (only if tmux is enabled)
    programs.tmux.tmuxinator.projects = lib.mkIf config.programs.tmux.enable {
      primary = mkTmuxinatorProject "primary" "~/Documents/pallet/copallet";
      "wt-1" = mkTmuxinatorProject "wt-1" "~/Documents/pallet/copallet-wt-1";
      "wt-2" = mkTmuxinatorProject "wt-2" "~/Documents/pallet/copallet-wt-2";
      "pallet-iac" = mkTmuxinatorProject "pallet-iac" "~/Documents/pallet/pallet-iac";
    };
  };
in {
  options.nixos.modules.work = mkModuleOption {};
  options.darwin.modules.work = mkModuleOption {};
  options.homeManager.modules.work = mkModuleOption {};

  config.homeManager.modules.work = hmModule;

  config.nixos.modules.work = {config, ...}: {
    home-manager.users.${config.mine.username}.imports = [hmModule];
  };

  config.darwin.modules.work = {config, ...}: {
    home-manager.users.${config.mine.username}.imports = [hmModule];
    homebrew.taps = ["schpet/tap"];
    homebrew.brews = ["schpet/tap/linear"];
    homebrew.casks = ["linear"];
  };
}
