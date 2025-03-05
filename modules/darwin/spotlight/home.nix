{ config, pkgs, bconfig, lib, ... }: {
  home.activation = {
    aliasHomeManagerApplications = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      app_folder="${config.home.homeDirectory}/Applications/Home Manager Trampolines"
      rm -rf "$app_folder"
      mkdir -p "$app_folder"
      for app in $(find "$genProfilePath/home-path/Applications" -type l); do
          app_target="$app_folder/$(basename $app)"
          real_app="$(readlink $app)"
          echo "mkalias \"$real_app\" \"$app_target\"" >&2
          $DRY_RUN_CMD ${pkgs.mkalias}/bin/mkalias "$real_app" "$app_target"
      done
    '';
  };
}
