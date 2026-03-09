{pkgs, lib, ...}: let
  linear-tui = pkgs.buildGoModule {
    pname = "linear-tui";
    version = "unstable-2025-03-09";

    src = pkgs.fetchFromGitHub {
      owner = "roeyazroel";
      repo = "linear-tui";
      rev = "cb8942c10b8cfb1c911c01e8340c0208bc4ff029";
      hash = lib.fakeHash;
    };

    vendorHash = lib.fakeHash;

    subPackages = ["cmd/linear-tui"];

    meta = {
      description = "A terminal user interface (TUI) for Linear built with Go";
      homepage = "https://github.com/roeyazroel/linear-tui";
      mainProgram = "linear-tui";
    };
  };
in {
  home.packages = [linear-tui];
}
