{
  pkgs,
  config,
  lib,
  ...
}: let
  yaml = pkgs.formats.yaml {};

  mkTmuxinatorProject = name: root:
    yaml.generate "${name}.yml" {
      inherit name;
      root = root;
      windows = [
        {claude = "ccp";}
        {editor = null;}
        {driver = null;}
        {
          build = {
            layout = "even-horizontal";
            panes = [
              "cd backend"
              "cd frontend"
              "cd packages/tasks"
            ];
          };
        }
      ];
    };
in {
  home.packages = with pkgs; [
    gh
    gh-dash
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

    (writeShellScriptBin "pcursor" ''
      cursor ~/Documents/pallet/copallet &
      cursor ~/Documents/pallet/copallet-wt-1 &
      cursor ~/Documents/pallet/copallet-wt-2 &
    '')
  ];

  # Tmuxinator project configs (only if tmux is enabled)
  xdg.configFile = lib.mkIf config.programs.tmux.enable {
    "tmuxinator/primary.yml".source = mkTmuxinatorProject "primary" "~/Documents/pallet/copallet";
    "tmuxinator/wt-1.yml".source = mkTmuxinatorProject "wt-1" "~/Documents/pallet/copallet-wt-1";
    "tmuxinator/wt-2.yml".source = mkTmuxinatorProject "wt-2" "~/Documents/pallet/copallet-wt-2";
  };
}
