{lib, ...}: let
  inherit (import ../../dendritic-lib.nix {inherit lib;}) mkHmFeature;
in
  mkHmFeature "claude" (
    {
      pkgs,
      lib,
      config,
      ...
    }: let
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
        version = "1.6.6";
        src = pkgs.fetchFromGitHub {
          owner = "veelenga";
          repo = "claude-mermaid";
          rev = "c58713771f5f3b4632b8ce907743a050831a5fed";
          hash = "sha256-ViqDL193NOaat526VGFqu4RxZFqvPVenjrq3WacnxcA=";
        };
        npmDepsHash = "sha256-FFHUkPgzDzegWPmk0v9/9OeLrfnS65APDpFKVSX/qAU=";
        npmBuildScript = "build";
        PUPPETEER_SKIP_DOWNLOAD = "true";
        nativeBuildInputs = [pkgs.makeWrapper];
        postInstall = ''
          wrapProgram $out/bin/claude-mermaid \
            --set PUPPETEER_EXECUTABLE_PATH "${
            if pkgs.stdenv.hostPlatform.isDarwin
            then "${pkgs.google-chrome}/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
            else "${pkgs.chromium}/bin/chromium"
          }"
        '';
      };

      claude-sync = pkgs.writeShellApplication {
        name = "claude-sync";
        runtimeInputs = [
          pkgs.jq
          pkgs.rsync
          pkgs.openssh
        ];
        excludeShellChecks = ["SC2016"];
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
        runtimeInputs = [pkgs.jq];
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
    in {
      options.mine.claude.extraMcpServers = lib.mkOption {
        type = lib.types.attrsOf (lib.types.attrsOf lib.types.anything);
        default = {};
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
          for f in .env .env.mcp; do
            if [ -f "$f" ]; then
              set -a
              . "./$f"
              set +a
            fi
          done
          ${claude-code}/bin/claude --dangerously-skip-permissions
        '')

        (writeShellScriptBin "ccpm" ''
          for f in .env .env.mcp; do
            if [ -f "$f" ]; then
              set -a
              . "./$f"
              set +a
          fi
          done
          export CLAUDE_CONFIG_DIR="$HOME/.claude-personal"
          exec ${claude-code}/bin/claude --dangerously-skip-permissions "$@"
        '')
      ];

      config.home.file.".claude/CLAUDE.md".source = ./CLAUDE.md;
      config.home.file.".claude-personal/CLAUDE.md".source = ./CLAUDE.md;

      config.home.activation.claudeSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
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
