{
  pkgs,
  lib,
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
    nativeBuildInputs = [pkgs.makeWrapper];
    postInstall = lib.optionalString pkgs.stdenv.isLinux ''
      wrapProgram $out/bin/claude-mermaid \
        --set PUPPETEER_EXECUTABLE_PATH "${pkgs.chromium}/bin/chromium"
    '';
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
    };

    preferredNotifChannel = "terminal_bell";
    editorMode = "vim";
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
              command = "active=$(tmux display -t \"$TMUX_PANE\" -p '#{window_active}'); attached=$(tmux display -t \"$TMUX_PANE\" -p '#{session_attached}'); if [ \"$active\" = \"0\" ] || [ \"$attached\" = \"0\" ]; then tmux set-window-option -t \"$TMUX_PANE\" @notified 1; fi";
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

  claudeKeybindingsFile = pkgs.writeText "claude-keybindings.json" (builtins.toJSON claudeKeybindings);
in {
  home.packages = with pkgs; [
    claude-monitor
    claude-mermaid
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

  home.activation.claudeSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD mkdir -p $HOME/.claude $HOME/.claude-personal
    $DRY_RUN_CMD rm -f $HOME/.claude/settings.json $HOME/.claude-personal/settings.json
    $DRY_RUN_CMD install -m 644 ${claudeSettingsFile} $HOME/.claude/settings.json
    $DRY_RUN_CMD install -m 644 ${claudeSettingsFile} $HOME/.claude-personal/settings.json
    $DRY_RUN_CMD rm -f $HOME/.claude/keybindings.json $HOME/.claude-personal/keybindings.json
    $DRY_RUN_CMD install -m 644 ${claudeKeybindingsFile} $HOME/.claude/keybindings.json
    $DRY_RUN_CMD install -m 644 ${claudeKeybindingsFile} $HOME/.claude-personal/keybindings.json
  '';
}
