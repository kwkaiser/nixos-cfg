{ mkModuleOption, ... }:
let
  hmModule = { pkgs, config, lib, ... }: {
    home.activation.removeStaleHyprlandLua = lib.hm.dag.entryBefore ["writeBoundary"] ''
      rm -f "$HOME/.config/hypr/hyprland.lua" "$HOME/.config/hypr/hyprlandd.lua"
    '';

    home.packages = with pkgs; [
      wl-clipboard
      wf-recorder
      awww
      jq
      bibata-cursors
      thunar
      tumbler
      imv
      sway-contrib.grimshot
      hyprpolkitagent
      pavucontrol

      (pkgs.writeShellScriptBin "gparted" ''
        sudo WAYLAND_DISPLAY="$WAYLAND_DISPLAY" XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" ${pkgs.gparted}/bin/gparted "$@"
      '')
      (pkgs.writeShellScriptBin "getIdx" ''
        hyprctl activewindow -j | jq -r '. as $win | ($win.grouped | index($win.address)) as $idx | { index: $idx, size: (.grouped | length) }'
      '')

      (pkgs.writeShellScriptBin "shiftTabLeft" ''
        idx=$(getIdx | jq -r .index)
        if [ -z "$idx" ] || [ "$idx" = "null" ]; then
          hyprctl dispatch moveintogroup l
        elif [ "$idx" -eq 0 ]; then
          hyprctl dispatch moveoutofgroup l
        else
          hyprctl dispatch movegroupwindow b
        fi
      '')

      (pkgs.writeShellScriptBin "shiftTabRight" ''
        idx=$(getIdx | jq -r .index)
        size=$(getIdx | jq -r .size)

        if [ -z "$idx" ] || [ "$idx" = "null" ]; then
          hyprctl dispatch moveintogroup r
        elif [ "$idx" -eq $((size - 1)) ]; then
          hyprctl dispatch moveoutofgroup r
        else
          hyprctl dispatch movegroupwindow f
        fi
      '')

      (pkgs.writeShellScriptBin "rain-lock" ''
        ${pkgs.swaylock-plugin}/bin/swaylock-plugin \
          --color 000000 \
          --command-each '${pkgs.windowtolayer}/bin/windowtolayer -- ${pkgs.kitty}/bin/kitty -e ${pkgs.terminal-rain-lightning}/bin/terminal-rain'
      '')

      (pkgs.writeShellScriptBin "hypr-session-init" ''
        set -u
        exec >>"$HOME/.cache/hypr-session-init.log" 2>&1
        echo "$(date -Is): starting for $HYPRLAND_INSTANCE_SIGNATURE"

        for _ in $(seq 1 100); do
          hyprctl monitors >/dev/null 2>&1 && break
          sleep 0.1
        done

        for _ in $(seq 1 50); do
          hyprctl -j monitors | jq -e '.[] | select(.name == "moonlight")' >/dev/null 2>&1 && break
          hyprctl output create headless moonlight >/dev/null 2>&1
          sleep 0.2
        done
        hyprctl keyword monitor "moonlight,1920x1080@60,5000x0,1"

        systemctl --user start hyprland-session.target
        systemctl --user start hyprpolkitagent
        echo "$(date -Is): done for $HYPRLAND_INSTANCE_SIGNATURE"
      '')

      (pkgs.writeShellScriptBin "hypr-output-bootstrap" ''
        set -u
        exec >>"$HOME/.cache/hypr-output-bootstrap.log" 2>&1
        echo "$(date -Is): watcher starting"
        seen=""
        while true; do
          for sig_dir in "$XDG_RUNTIME_DIR"/hypr/*/; do
            [ -d "$sig_dir" ] || continue
            sig=$(basename "$sig_dir")
            case " $seen " in
              *" $sig "*) continue ;;
            esac
            [ -S "''${sig_dir}.socket.sock" ] || continue
            seen="$seen $sig"
            echo "$(date -Is): found new hyprland instance $sig"
            HYPRLAND_INSTANCE_SIGNATURE="$sig" hypr-session-init &
          done
          sleep 1
        done
      '')
    ];

    home.sessionVariables = {
      GDK_BACKEND = "wayland,x11";
      QT_QPA_PLATFORM = "wayland;xcb";
      #SDL_VIDEODRIVER = "x11"; # set via hyprland env instead so it applies to non-shell-spawned processes
      CLUTTER_BACKEND = "wayland";
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "Hyprland";
      WLR_NO_HARDWARE_CURSORS = "1";
    };

    wayland.windowManager.hyprland = {
      enable = true;
      package = pkgs.hyprland;
      configType = "hyprlang";
      # Automatically import all environment variables for systemd services
      # This fixes issues where programs don't work in systemd services but do in terminal
      systemd.variables = ["--all"];
      settings.env = [
        "SDL_VIDEODRIVER,x11"
        "XCURSOR_THEME,Bibata-Modern-Classic"
        "XCURSOR_SIZE,24"
      ];
    };

    systemd.user.services.hypr-output-bootstrap = {
      Unit.Description = "Creates the headless moonlight output for each new Hyprland session";
      Service = {
        ExecStart = "${config.home.profileDirectory}/bin/hypr-output-bootstrap";
        Restart = "always";
        RestartSec = 1;
      };
      Install.WantedBy = ["default.target"];
    };

    services.gammastep = {
      enable = true;
      latitude = 42.35;
      longitude = -71.05;
    };

    home.pointerCursor = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };

    wayland.windowManager.hyprland.settings = {
      input = {
        accel_profile = "flat";
        force_no_accel = true;
      };

      monitor = ["DP-2,1920x1080@144,0x0,1,transform,1" "DP-1,1920x1080@144,1080x0,1"];

      # Workspace assignments
      workspace = [
        # Workspaces 1-5 on left monitor (DP-1)
        "1, monitor:DP-2"
        "2, monitor:DP-2"
        "3, monitor:DP-2"
        "4, monitor:DP-2"
        "5, monitor:DP-2"
        # Workspaces 6-10 on right monitor (DP-2)
        "6, monitor:DP-1"
        "7, monitor:DP-1"
        "8, monitor:DP-1"
        "9, monitor:DP-1"
        "10, monitor:DP-1"
      ];

      exec-once = [
        # systemd.variables handles dbus-update-activation-environment automatically
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "sleep 1 && waybar &"
        "swaync &"
        "sleep 1 && swww-daemon && sleep 1 && swww img $(find ~/Documents/nixos-cfg/assets/backgrounds -type f | sort -R | head -n1) &"
      ];
      "$mod" = "SUPER";
      "$terminal" = "kitty";

      bind =
        [
          "$mod, Return, exec, $terminal"
          "$mod SHIFT, Q, killactive"
          "$mod SHIFT, E, exit"
          "$mod SHIFT, X, exec, rain-lock"
          "$mod, f, fullscreen"
          "$mod SHIFT, R, exec, hyprctl reload && notify-send 'Hyprland' 'Config reloaded'"
          "$mod, m, exec, shiftTabLeft"

          # Screenshots
          "$mod SHIFT, C, exec, grimshot save area ~/Documents/screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"
          "$mod, c, exec, grimshot copy area"

          # Navigation
          "$mod, h, movefocus, l"
          "$mod, l, movefocus, r"
          "$mod, j, movefocus, d"
          "$mod, k, movefocus, u"
          "$mod SHIFT, h, movewindow, l"
          "$mod SHIFT, l, movewindow, r"
          "$mod SHIFT, j, movewindow, d"
          "$mod SHIFT, k, movewindow, u"

          # Layout management (similar to sway)
          "$mod, w, exec, hyprctl dispatch layoutmsg orientationtop"
          "$mod, s, togglegroup"
          "$mod, e, moveoutofgroup"
          "$mod, v, exec, hyprctl dispatch layoutmsg orientationbottom"
          "$mod SHIFT, v, exec, hyprctl dispatch layoutmsg orientationright"

          # Tabbing
          "$mod, bracketleft, changegroupactive, b"
          "$mod, bracketright, changegroupactive, f"
          "$mod SHIFT, bracketleft, exec, shiftTabLeft"
          "$mod SHIFT, bracketright, exec, shiftTabRight"

          # Misc programs
          "$mod SHIFT, f, exec, thunar"
          "$mod, b, exec, obsidian"

          # Notifications
          "$mod SHIFT, b, exec, swaync-client -C"
          "$mod SHIFT, n, exec, swaync-client -t"
          "$mod, n, exec, swaync-client --close-latest"

          # Audio
          "$mod, code:96, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          "$mod, code:95, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          "$mod, code:76, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"

          "$mod SHIFT, code:96, exec, playerctl next"
          "$mod SHIFT, code:95, exec, playerctl play-pause"
          "$mod SHIFT, code:76, exec, playerctl previous"

          # Workspaces
        ]
        ++ (builtins.concatLists (builtins.genList (i: let
            ws = i + 1;
          in [
            "$mod, ${toString ws}, workspace, ${toString ws}"
            "$mod SHIFT, ${toString ws}, movetoworkspace, ${toString ws}"
          ])
          9))
        ++ [
          "$mod, 0, workspace, 10"
        ]
        # Application launch keybinds
        ++ [
          "$mod, D, exec, sh -c 'ACTIVE_MONITOR=$(hyprctl monitors -j | jq -r \".[] | select(.focused == true) | .name\"); MONITOR_FLAG=\"\"; if [ \"$ACTIVE_MONITOR\" = \"DP-2\" ]; then MONITOR_FLAG=\"-monitor 0\"; else MONITOR_FLAG=\"-monitor 1\"; fi; SELECTION=$(hyprctl clients -j | jq -r \".[] | select(.workspace.id != -99) | .title\" | rofi -dmenu -i -p \"Window\" $MONITOR_FLAG); if [ -n \"$SELECTION\" ]; then ADDRESS=$(hyprctl clients -j | jq -r \".[] | select(.title == \\\"$SELECTION\\\") | .address\" | head -1); hyprctl dispatch focuswindow address:\"$ADDRESS\"; fi'"
          "$mod SHIFT, D, exec, sh -c 'ACTIVE_MONITOR=$(hyprctl monitors -j | jq -r \".[] | select(.focused == true) | .name\"); if [ \"$ACTIVE_MONITOR\" = \"DP-2\" ]; then rofi -show drun -monitor 0; else rofi -show drun -monitor 1; fi'"
        ];

      group = {
        groupbar = {
          enabled = true;
          font_size = 12;
          height = 18;
          render_titles = true;
          scrolling = true;
        };
      };

      animations = {
        enabled = true;

        bezier = [
          "wind, 0.05, 0.9, 0.1, 1.05"
          "winIn, 0.1, 1.1, 0.1, 1.1"
          "winOut, 0.3, -0.3, 0, 1"
          "liner, 1, 1, 1, 1"
        ];

        animation = [
          "windows, 1, 3, wind, slide"
          "windowsIn, 1, 3, winIn, slide"
          "windowsOut, 1, 2, winOut, slide"
          "windowsMove, 1, 3, wind, slide"
          "border, 1, 1, liner"
          "borderangle, 1, 4, liner"
          "fade, 1, 5, default"
          "workspaces, 1, 3, wind"
        ];
      };
    };

    programs.hyprlock.enable = true;
    programs.hyprlock.settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor = true;
        no_fade_in = false;
      };

      input-field = {
        size = "200, 50";
        position = "0, -80";
        monitor = "";
        dots_center = true;
        fade_on_empty = false;
        outline_thickness = 5;
        placeholder_text = "Unlock:";
        shadow_passes = 2;
      };
    };
  };
in
{
  options.nixos.modules.hyprland = mkModuleOption { };

  config.nixos.modules.hyprland = { pkgs, lib, config, ... }: let
    # Speaks greetd's IPC protocol directly (the same protocol tuigreet uses)
    # to log in and start Hyprland without a physical console, so PAM modules
    # tied to the real password (e.g. gnome-keyring unlock) still fire, unlike
    # a greetd `initial_session` autologin. See greetd-remote-login.py.
    greetdRemoteLoginPy = pkgs.writers.writePython3Bin "greetd-remote-login-py"
      { } (builtins.readFile ./hyprland/greetd-remote-login.py);

    greetdRemoteLogin = pkgs.writeShellScriptBin "greetd-remote-login" ''
      exec ${greetdRemoteLoginPy}/bin/greetd-remote-login-py \
        --user ${lib.escapeShellArg config.mine.username} \
        -- ${pkgs.hyprland}/bin/start-hyprland
    '';
  in {
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

    home-manager.users.${config.mine.username}.imports = [ hmModule ];
  };
}
