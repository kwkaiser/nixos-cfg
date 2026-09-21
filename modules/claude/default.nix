{ lib, ... }:
let
  inherit (import ../../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "claude" (
  {
    pkgs,
    lib,
    config,
    ...
  }:
  let
    tmux-mcp = pkgs.buildNpmPackage {
      pname = "tmux-mcp";
      version = "0.2.2";
      src = pkgs.fetchFromGitHub {
        owner = "nickgnd";
        repo = "tmux-mcp";
        rev = "ec68b1061cf3b0d1faa9c5ef5e3f703918e07ba8";
        hash = "sha256-rZhVjuWRlVSjLthgSKbfuPpQQKP9YC2Pjun/6JQYUo0=";
      };
      npmDepsHash = "sha256-N1j8yBC1zQiUTnpfVw2ppY2kh4kJvT88kpTlB1kCBKY=";
    };

    claude-mermaid = pkgs.buildNpmPackage {
      pname = "claude-mermaid";
      version = "1.6.4";
      src = pkgs.fetchFromGitHub {
        owner = "veelenga";
        repo = "claude-mermaid";
        rev = "f56a1b43b53e97c66a0b8afbb1ad0cd67da1afb3";
        hash = "sha256-ZOavR51CTUaEUAOGItDNvHPcowgwJQTLXtpFt6oqnOA=";
      };
      npmDepsHash = "sha256-GN1bE+LS/DE5CARydzHkvPnE7doIP+WmNQllL9WSi+k=";
      npmBuildScript = "build";
      PUPPETEER_SKIP_DOWNLOAD = "true";
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postInstall = lib.optionalString pkgs.stdenv.hostPlatform.isLinux ''
        wrapProgram $out/bin/claude-mermaid \
          --set PUPPETEER_EXECUTABLE_PATH "${pkgs.chromium}/bin/chromium"
      '';
    };

    claude-sync = pkgs.writeShellApplication {
      name = "claude-sync";
      runtimeInputs = [
        pkgs.jq
        pkgs.rsync
        pkgs.openssh
      ];
      excludeShellChecks = [ "SC2016" ];
      text = builtins.readFile ./claude-sync.sh;
    };

    forbiddenCommands = [
      "ssh-agent"
      "ssh-add"
      "keepassxc-cli"
      "kpcli"
    ];

    forbiddenPattern = lib.concatStringsSep "|" forbiddenCommands;

    claudeSettings = {
      env = {
        ENABLE_LSP_TOOL = "1";
        CLAUDE_CODE_NO_FLICKER = "1";
      };

      preferredNotifChannel = "terminal_bell";
      editorMode = "vim";
      diffSidebarOpen = false;
      voice = {
        enabled = true;
        mode = "hold";
      };

      enabledPlugins = {
        "context-mode@claude-context-mode" = true;
      };

      hooks = {
        PreToolUse = [
          {
            matcher = "Bash";
            hooks = [
              {
                type = "command";
                command = ''
                  if cat | grep -qE '${forbiddenPattern}'; then
                    echo 'Blocked: This command is not allowed' >&2
                    exit 2
                  fi
                '';
              }
            ];
          }
        ];
        Stop = [
          {
            hooks = [
              {
                type = "command";
                command = "stdin=$(cat); echo \"$(date -Iseconds) $stdin\" >> /tmp/claude-stop-debug.log; active=$(tmux display -t \"$TMUX_PANE\" -p '#{window_active}'); attached=$(tmux display -t \"$TMUX_PANE\" -p '#{session_attached}'); if [ \"$active\" = \"0\" ] || [ \"$attached\" = \"0\" ]; then tmux set-window-option -t \"$TMUX_PANE\" @notified 1; fi";
              }
            ];
          }
        ];
        Notification = [
          {
            hooks = [
              {
                type = "command";
                command = "active=$(tmux display -t \"$TMUX_PANE\" -p '#{window_active}'); attached=$(tmux display -t \"$TMUX_PANE\" -p '#{session_attached}'); if [ \"$active\" = \"0\" ] || [ \"$attached\" = \"0\" ]; then tmux set-window-option -t \"$TMUX_PANE\" @notified 1; fi";
              }
            ];
          }
        ];
      };
    };

    claudeSettingsFile = pkgs.writeText "claude-settings.json" (builtins.toJSON claudeSettings);

    claude-settings-merge = pkgs.writeShellApplication {
      name = "claude-settings-merge";
      runtimeInputs = [ pkgs.jq ];
      text = builtins.readFile ./settings-merge.sh;
    };

    claudeMcpServers = {
      mermaid = {
        command = "${claude-mermaid}/bin/claude-mermaid";
      };
      notion = {
        type = "http";
        url = "https://mcp.notion.com/mcp";
      };
      jira = {
        type = "http";
        url = "https://mcp.atlassian.com/v1/mcp/authv2";
      };
    };

    claudeMcpServersFile = pkgs.writeText "claude-mcp-servers.json" (builtins.toJSON claudeMcpServers);

    ccpMcpServersFile = pkgs.writeText "claude-ccp-mcp-servers.json" (
      builtins.toJSON (claudeMcpServers // config.mine.claude.extraMcpServers)
    );

    claudeKeybindings = {
      "$schema" = "https://www.schemastore.org/claude-code-keybindings.json";
      "$docs" = "https://code.claude.com/docs/en/keybindings";
      bindings = [
        {
          context = "Chat";
          bindings = {
            "ctrl+space" = "voice:pushToTalk";
          };
        }
      ];
    };

    claudeKeybindingsFile = pkgs.writeText "claude-keybindings.json" (
      builtins.toJSON claudeKeybindings
    );
  in
  {
    options.mine.claude.extraMcpServers = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.anything);
      default = { };
      description = "Extra global MCP servers, added to the `ccp` instance only.";
    };

    config.home.packages = with pkgs; [
      claude-code
      claude-monitor
      claude-mermaid
      claude-sync
      tmux-mcp
      nodejs

      (writeShellScriptBin "ccp" ''
        ${claude-code}/bin/claude --dangerously-skip-permissions
      '')

      (writeShellScriptBin "ccpm" ''
        export CLAUDE_CONFIG_DIR="$HOME/.claude-personal"
        exec ${claude-code}/bin/claude --dangerously-skip-permissions "$@"
      '')
    ];

    config.home.file.".claude/CLAUDE.md".source = ./CLAUDE.md;
    config.home.file.".claude-personal/CLAUDE.md".source = ./CLAUDE.md;

    config.home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p $HOME/.claude $HOME/.claude-personal
      for d in $HOME/.claude $HOME/.claude-personal; do
        $DRY_RUN_CMD ${claude-settings-merge}/bin/claude-settings-merge \
          "$d/settings.json" ${claudeSettingsFile}
      done
      $DRY_RUN_CMD rm -f $HOME/.claude/keybindings.json $HOME/.claude-personal/keybindings.json
      $DRY_RUN_CMD install -m 644 ${claudeKeybindingsFile} $HOME/.claude/keybindings.json
      $DRY_RUN_CMD install -m 644 ${claudeKeybindingsFile} $HOME/.claude-personal/keybindings.json

      mergeMcpServers() {
        f="$1"
        servers="$2"
        if [ -f "$f" ]; then
          ${pkgs.jq}/bin/jq \
            --argjson servers "$(cat "$servers")" \
            '.mcpServers = ((.mcpServers // {}) + $servers)' \
            "$f" > "$f.tmp" && mv "$f.tmp" "$f"
        else
          ${pkgs.jq}/bin/jq -n \
            --argjson servers "$(cat "$servers")" \
            '{mcpServers: $servers}' > "$f"
        fi
      }

      $DRY_RUN_CMD mergeMcpServers $HOME/.claude.json ${ccpMcpServersFile}
      $DRY_RUN_CMD mergeMcpServers $HOME/.claude-personal/.claude.json ${claudeMcpServersFile}
    '';
  }
)
