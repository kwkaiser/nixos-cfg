{
  pkgs,
  inputs,
  ...
}:
{
  home.packages = [
    # Current nixos-unstable's ld64/libclang_rt combo crashes
    # (Trace/BPT trap: 5) linking codex's livekit-libwebrtc dependency
    # on Darwin.
    inputs.nixpkgs-darwin-stable.legacyPackages.${pkgs.system}.codex
  ];
}
