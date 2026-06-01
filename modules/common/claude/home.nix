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

  home.file.".claude/settings.json".text = builtins.toJSON claudeSettings;
  home.file.".claude/settings.json".force = true;
  home.file.".claude-personal/settings.json".text = builtins.toJSON claudeSettings;
  home.file.".claude-personal/settings.json".force = true;
}
