{ mkModuleOption, ... }:
let
  hmModule = { pkgs, lib, ... }: {
    # Always install messaging packages through home-manager
    # signal-desktop and slack are excluded on Darwin — installed via Homebrew cask instead
    home.packages =
      with pkgs;
      [
        caprine
        discord
      ]
      ++ lib.optionals (!pkgs.stdenv.isDarwin) [
        signal-desktop
        slack
      ];

    services.kdeconnect.enable = lib.mkIf (!pkgs.stdenv.isDarwin) true;
  };
in
{
  options.nixos.modules.messaging = mkModuleOption { };
  options.darwin.modules.messaging = mkModuleOption { };
  options.homeManager.modules.messaging = mkModuleOption { };

  config.homeManager.modules.messaging = hmModule;

  config.nixos.modules.messaging = { config, ... }: {
    home-manager.users.${config.mine.username}.imports = [ hmModule ];
    # Firewall rules for KDE Connect (non-Darwin only)
    networking.firewall = rec {
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
      allowedUDPPortRanges = allowedTCPPortRanges;
    };
  };

  config.darwin.modules.messaging = { config, ... }: {
    home-manager.users.${config.mine.username}.imports = [ hmModule ];
    # Use Homebrew cask on Darwin to stay on the latest Signal release;
    # nixpkgs signal-desktop lags and causes database version mismatch errors
    #
    # slack is also cask-only on Darwin: home-manager's app-trampoline rsync
    # (--chmod=-w over Slack.app's signed bundle) gets blocked by endpoint
    # security software on managed devices, which aborts the whole activation
    homebrew.casks = [
      "signal"
      "slack"
    ];
  };
}
