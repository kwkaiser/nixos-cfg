{
  pkgs,
  lib,
  inputs,
  ...
}: let
  # Pinned nixpkgs for claude-code until nixos-unstable fixes the yanked 2.1.88 version
  claude-code-pkgs = import inputs.nixpkgs-claude-code {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };
  forbiddenCommands = [
    "ssh-agent"
    "ssh-add"
    "keepassxc-cli"
    "kpcli"
  ];

  forbiddenPattern = lib.concatStringsSep "|" forbiddenCommands;

  claudeSettings = {
    enabledPlugins = {
      "context-mode@claude-context-mode" = true;
      "superpowers@claude-plugins-official" = true;
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
    claude-code-pkgs.claude-code
    claude-monitor

    (writeShellScriptBin "ccp" ''
      ${claude-code-pkgs.claude-code}/bin/claude --dangerously-skip-permissions
    '')

    (writeShellScriptBin "ccpm" ''
      export CLAUDE_CONFIG_DIR="$HOME/.claude-personal"
      exec ${claude-code-pkgs.claude-code}/bin/claude --dangerously-skip-permissions "$@"
    '')
  ];

  home.file.".claude/settings.json".text = builtins.toJSON claudeSettings;
  home.file.".claude-personal/settings.json".text = builtins.toJSON claudeSettings;
}
