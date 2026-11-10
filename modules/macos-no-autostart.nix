{ mkModuleOption, ... }:
{
  options.darwin.modules.macos-no-autostart = mkModuleOption { };

  config.darwin.modules.macos-no-autostart = { pkgs, config, ... }:
    let
      clearLoginItems = pkgs.writeShellScript "clear-login-items" ''
        /usr/bin/osascript -e 'tell application "System Events" to delete every login item' >/dev/null 2>&1 || true
      '';
    in
    {
      system.defaults.CustomUserPreferences."com.apple.loginwindow" = {
        TALLogoutSavesState = false;
        LoginwindowLaunchesRelaunchApps = false;
      };

      system.activationScripts.postActivation.text = ''
        sudo -u ${config.mine.username} ${clearLoginItems}
      '';

      launchd.user.agents.clear-login-items = {
        serviceConfig = {
          ProgramArguments = [ "${clearLoginItems}" ];
          RunAtLoad = true;
          StartInterval = 300;
        };
      };
    };
}
