{
  config,
  pkgs,
  inputs,
  ...
}:
{
  home.packages = with pkgs; [
    claude-code
    claude-monitor

    (writeShellScriptBin "ccp" ''
      claude --dangerously-skip-permissions
    '')
  ];
}
