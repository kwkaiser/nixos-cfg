{ pkgs, lib, config, ... }:
let
  # Speaks greetd's IPC protocol directly (the same protocol tuigreet uses)
  # to log in and start Hyprland without a physical console, so PAM modules
  # tied to the real password (e.g. gnome-keyring unlock) still fire, unlike
  # a greetd `initial_session` autologin. See greetd-remote-login.py.
  greetdRemoteLoginPy = pkgs.writers.writePython3Bin "greetd-remote-login-py"
    { } (builtins.readFile ./greetd-remote-login.py);

  greetdRemoteLogin = pkgs.writeShellScriptBin "greetd-remote-login" ''
    exec ${greetdRemoteLoginPy}/bin/greetd-remote-login-py \
      --user ${lib.escapeShellArg config.mine.username} \
      -- ${pkgs.hyprland}/bin/start-hyprland
  '';
in {

  options = {
    mine.hyprland.enable = lib.mkEnableOption "Enables hyprland desktop";
  };

  config = lib.mkIf config.mine.hyprland.enable {
    xdg.portal.enable = true;
    xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
    programs.hyprland.enable = true;

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          # No --remember: with a remembered username, tuigreet calls
          # greetd's create_session itself the instant it starts (no
          # keypress needed), racing greetd-remote-login for the single
          # global session-negotiation slot - greetd's cancel-on-disconnect
          # cleanup isn't scoped per-connection, so whichever loses that
          # race gets silently cancelled out from under it.
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd ${pkgs.hyprland}/bin/start-hyprland";
          user = "greeter";
        };
      };
    };

    # Lets `greetd-remote-login` (run via sudo) connect to greetd's
    # session-broker socket, which is owned by the greeter user.
    environment.systemPackages = [ greetdRemoteLogin ];

    security.pam.services.hyprlock = { };
    security.pam.services.swaylock = { };

    # Home manager config
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}

