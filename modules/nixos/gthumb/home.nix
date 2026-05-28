{pkgs, ...}: {
  home.packages = [
    # gthumb's slideshow extension loads clutter 1.26.4, which uses the
    # deprecated wl_shell protocol not implemented by Hyprland, causing an
    # infinite hang on startup. Strip the extension to avoid loading clutter.
    (pkgs.gthumb.overrideAttrs (old: {
      postInstall =
        (old.postInstall or "")
        + ''
          rm -f $out/lib/gthumb/extensions/libslideshow.so
          rm -f $out/lib/gthumb/extensions/slideshow.extension
        '';
    }))
  ];
}
