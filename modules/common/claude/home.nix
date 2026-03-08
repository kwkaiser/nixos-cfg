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
    "op"
  ];

  forbiddenPattern = lib.concatStringsSep "|" forbiddenCommands;

  claudeSettings = {
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
    };
  };
in {
  home.packages = with pkgs; [
    claude-code
    claude-monitor

    (writeShellScriptBin "ccp" ''
      claude --dangerously-skip-permissions
    '')
  ];

  home.file.".claude/settings.json".text = builtins.toJSON claudeSettings;
}
