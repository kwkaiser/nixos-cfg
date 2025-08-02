{ pkgs, config, lib, inputs, ... }: {
  # Script used to get spotlight search working for applications. 
  # See https://github.com/LnL7/nix-darwin/issues/214

  system.activationScripts.spotlightApps.text = ''
  apps_source="${config.system.build.applications}/Applications"
  moniker="Nix Trampolines"
  app_target_base="$HOME/Applications"
  app_target="$app_target_base/$moniker"
  mkdir -p "$app_target"
  ${pkgs.rsync}/bin/rsync --archive --checksum --chmod=-w --copy-unsafe-links --delete "$apps_source/" "$app_target"
'';

  home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
}
