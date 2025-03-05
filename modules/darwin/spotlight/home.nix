{ config, pkgs, bconfig, ... }: {
  home.activation.linkHomeManagerApps = ''
    appSrc="${config.home.homeDirectory}/.nix-profile/Applications"
    appDest="/Applications/Home Manager Apps"

    mkdir -p "$appDest"

    find "$appSrc" -name "*.app" -type d | while read -r app; do
      basename=$(basename "$app")
      ln -sf "$app" "$appDest/$basename"
    done
  '';
}
