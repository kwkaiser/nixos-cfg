{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: let
  yaml = pkgs.formats.yaml {};

  devbox = inputs.nixpkgs-devbox.legacyPackages.${pkgs.stdenv.hostPlatform.system}.devbox;

  genai-toolbox = let
    platforms = {
      "x86_64-linux" = {
        os = "linux";
        arch = "amd64";
        sha256 = "sha256-F5SOdTiRQyDEFB0VW88oPJqMFoxqvOCa6Hg3BXiZuik=";
      };
      "aarch64-darwin" = {
        os = "darwin";
        arch = "arm64";
        sha256 = "sha256-esBNRWPGM7tEosGz7Jxaq18eWIViWv0/FZxz45lphJU=";
      };
    };
    platform = platforms.${pkgs.stdenv.hostPlatform.system};
  in
    pkgs.stdenv.mkDerivation rec {
      pname = "genai-toolbox";
      version = "1.1.0";
      src = pkgs.fetchurl {
        url = "https://storage.googleapis.com/genai-toolbox/v${version}/${platform.os}/${platform.arch}/toolbox";
        sha256 = platform.sha256;
      };
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out/bin
        cp $src $out/bin/bigquery-toolbox
        chmod +x $out/bin/bigquery-toolbox
      '';
    };

  mkTmuxinatorProject = name: root: extraWindows:
    yaml.generate "${name}.yml" {
      inherit name;
      root = root;
      windows =
        [
          {claude = "clear && ccp";}
          {editor = "clear";}
          {driver = "clear";}
        ]
        ++ extraWindows;
    };

  copalletBuildWindow = {
    build = {
      layout = "even-horizontal";
      panes = [
        "cd backend && clear"
        "cd frontend && clear"
        "cd packages/tasks && clear"
      ];
    };
  };

  # Script to pipe build output to neovim quickfix list
  nvb = pkgs.writeShellScriptBin "nvb" (builtins.readFile ./nvb.sh);
  # Script to pipe eslint output to neovim quickfix list
  nve = pkgs.writeShellScriptBin "nve" (builtins.readFile ./nve.sh);
  # Script to pipe vitest output to neovim quickfix list
  nvt = pkgs.writeShellScriptBin "nvt" (builtins.readFile ./nvt.sh);
in {
  home.packages = with pkgs; [
    devbox
    gh
    gh-dash
    awscli2
    google-cloud-sdk
    typescript-go
    vtsls
    ssm-session-manager-plugin
    nvb
    nve
    nvt
    (writeShellScriptBin "pnvb" ''
      pnpm run build:check --watch | nvb
    '')
    (writeShellScriptBin "pnvt" ''
      pnpm run test --watch | nvt
    '')
    (writeShellScriptBin "pnve" ''
      pnpm run lint --fix | nve
    '')

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

    genai-toolbox

    (writeShellScriptBin "pcursor" ''
      cursor ~/Documents/pallet/copallet &
      cursor ~/Documents/pallet/copallet-wt-1 &
      cursor ~/Documents/pallet/copallet-wt-2 &
    '')

    (writeShellScriptBin "bind-mermaid" ''
      host="''${1:?usage: bind-mermaid <ssh-host>}"
      exec ssh -N -L 3737:localhost:3737 -L 3738:localhost:3738 -L 3739:localhost:3739 "$host"
    '')
  ];

  # Tmuxinator project configs (only if tmux is enabled)
  xdg.configFile = lib.mkIf config.programs.tmux.enable {
    "tmuxinator/primary.yml".source = mkTmuxinatorProject "primary" "~/Documents/pallet/copallet" [copalletBuildWindow];
    "tmuxinator/wt-1.yml".source = mkTmuxinatorProject "wt-1" "~/Documents/pallet/copallet-wt-1" [copalletBuildWindow];
    "tmuxinator/wt-2.yml".source = mkTmuxinatorProject "wt-2" "~/Documents/pallet/copallet-wt-2" [copalletBuildWindow];
    "tmuxinator/pallet-iac.yml".source = mkTmuxinatorProject "pallet-iac" "~/Documents/pallet/pallet-iac" [];
  };
}
