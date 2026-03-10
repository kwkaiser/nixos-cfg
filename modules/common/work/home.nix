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
        {claude = "clear && ccp";}
        {editor = "clear";}
        {driver = "clear";}
        {
          build = {
            layout = "even-horizontal";
            panes = [
              "cd backend && clear"
              "cd frontend && clear"
              "cd packages/tasks && clear"
            ];
          };
        }
      ];
    };

  # Script to pipe build output to neovim quickfix list
  nvb = pkgs.writeShellScriptBin "nvb" (builtins.readFile ./nvb.sh);
  # Script to pipe eslint output to neovim quickfix list
  nve = pkgs.writeShellScriptBin "nve" (builtins.readFile ./nve.sh);
  # Script to pipe vitest output to neovim quickfix list
  nvt = pkgs.writeShellScriptBin "nvt" (builtins.readFile ./nvt.sh);
in {
  home.packages = with pkgs; [
    gh
    gh-dash
    nvb
    nve
    nvt
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
