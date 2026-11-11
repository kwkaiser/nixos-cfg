{ lib, ... }:
let
  inherit (import ../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "codex" (
  { pkgs, inputs, ... }:
  let
    # Current nixos-unstable's ld64/libclang_rt combo crashes
    # (Trace/BPT trap: 5) linking codex's livekit-libwebrtc dependency
    # on Darwin.
    codex = inputs.nixpkgs-darwin-cached.legacyPackages.${pkgs.stdenv.hostPlatform.system}.codex;
  in
  {
    home.packages = [
      (pkgs.symlinkJoin {
        name = "codex-${codex.version}";
        paths = [ codex ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/codex --add-flags "-c tui.vim_mode_default=true"
        '';
      })
    ];
  }
)
