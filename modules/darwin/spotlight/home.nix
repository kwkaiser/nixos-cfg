{
  config,
  pkgs,
  bconfig,
  lib,
  ...
}:
{
  home.activation = {
    rsync-home-manager-applications = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      rsyncArgs="--archive --checksum --chmod=-w --copy-unsafe-links --delete"

      # Find the home-manager applications directory
      apps_source=""
      if [[ -n "$newGenPath" ]]; then
        # Try the new generation path first
        apps_source="$newGenPath/home-path/Applications"
      elif [[ -n "$genProfilePath" ]]; then
        # Fallback to genProfilePath
        apps_source="$genProfilePath/home-path/Applications"
      else
        # Last resort: find the most recent home-manager-applications in nix store
        apps_source=$(find /nix/store -name "*home-manager-applications" -type d | sort | tail -1)/Applications
      fi

      moniker="Home Manager Trampolines"
      app_target_base="${config.home.homeDirectory}/Applications"
      app_target="$app_target_base/$moniker"

      echo "Syncing applications from: $apps_source"
      echo "Syncing applications to: $app_target"

      if [[ -d "$apps_source" && "$(ls -A "$apps_source" 2>/dev/null)" ]]; then
        mkdir -p "$app_target"
        ${pkgs.rsync}/bin/rsync $rsyncArgs "$apps_source/" "$app_target/"
        echo "Successfully synced $(ls -1 "$apps_source" | wc -l) applications"
      else
        echo "Warning: No applications found in $apps_source"
      fi
    '';
  };
}
