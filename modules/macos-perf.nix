{ mkModuleOption, ... }:
{
  options.darwin.modules.macos-perf = mkModuleOption { };

  config.darwin.modules.macos-perf = { config, ... }: {
    system.activationScripts.postActivation.text = ''
      touch /nix/.metadata_never_index

      uid=$(id -u ${config.mine.username})

      launchctl disable "gui/$uid/com.apple.photoanalysisd" >/dev/null 2>&1 || true
      launchctl bootout "gui/$uid/com.apple.photoanalysisd" >/dev/null 2>&1 || true
      launchctl disable "gui/$uid/com.apple.mediaanalysisd" >/dev/null 2>&1 || true
      launchctl bootout "gui/$uid/com.apple.mediaanalysisd" >/dev/null 2>&1 || true

      launchctl disable system/com.apple.rapportd >/dev/null 2>&1 || true
      launchctl bootout system/com.apple.rapportd >/dev/null 2>&1 || true
      launchctl disable "gui/$uid/com.apple.rapportd-user" >/dev/null 2>&1 || true
      launchctl bootout "gui/$uid/com.apple.rapportd-user" >/dev/null 2>&1 || true
      launchctl disable "gui/$uid/com.apple.RapportUIAgent" >/dev/null 2>&1 || true
      launchctl bootout "gui/$uid/com.apple.RapportUIAgent" >/dev/null 2>&1 || true
      launchctl disable "gui/$uid/com.apple.biomesyncd" >/dev/null 2>&1 || true
      launchctl bootout "gui/$uid/com.apple.biomesyncd" >/dev/null 2>&1 || true

      launchctl disable system/com.apple.coreduetd >/dev/null 2>&1 || true
      launchctl bootout system/com.apple.coreduetd >/dev/null 2>&1 || true
    '';
  };
}
