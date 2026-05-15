{pkgs, lib, isDarwin, ...}: {
  home.packages = lib.optionals (!isDarwin) (with pkgs; [
    prismlauncher
  ]);
}
