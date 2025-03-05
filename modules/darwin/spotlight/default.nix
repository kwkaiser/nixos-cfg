{ pkgs, config, lib, inputs, ... }: {
  system.activationScripts.applications.text = ''
    apps=$(ls ${pkgs.system-path}/Applications)
    for app in $apps; do
      if [ -d "${pkgs.system-path}/Applications/$app" ]; then
        ln -sf "${pkgs.system-path}/Applications/$app" "/Applications/$app"
      fi
    done
  '';

  home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
}
