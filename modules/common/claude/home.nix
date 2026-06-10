{
  pkgs,
  lib,
  ...
}: let
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

    editorMode = "vim";

    enabledPlugins = {
      "context-mode@claude-context-mode" = true;
      "superpowers@claude-plugins-official" = true;
      "vtsls@claude-code-lsps" = true;
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
    };
  };

  claudeSettingsFile = pkgs.writeText "claude-settings.json" (builtins.toJSON claudeSettings);
in {
  home.packages = with pkgs; [
    claude-monitor

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
  '';
}
