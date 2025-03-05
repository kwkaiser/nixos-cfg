{ pkgs, config, lib, inputs, ... }: {
  system.activationScripts.postUserActivation.text = ''
    app_folder="$HOME/Applications/Nix Trampolines"
    rm -rf "$app_folder"
    mkdir -p "$app_folder"
    for app in $(find "${config.system.build.applications}/Applications" -type l); do
        app_target="$app_folder/$(basename $app)"
        real_app="$(readlink $app)"
        echo "mkalias \"$real_app\" \"$app_target\"" >&2
        ${pkgs.mkalias}/bin/mkalias "$real_app" "$app_target"
    done
  '';

  home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
}
