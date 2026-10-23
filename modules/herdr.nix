{ lib, ... }:
let
  inherit (import ../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "herdr" (
  { config, pkgs, lib, ... }:
  let
    herdr = lib.getExe config.programs.herdr.package;

    sortTabs = pkgs.writeShellApplication {
      name = "herdr-sort-tabs";
      runtimeInputs = [
        pkgs.jq
        pkgs.socat
      ];
      text = ''
        workspace="$1"
        if [ -n "''${HERDR_SOCKET_PATH:-}" ]; then
          socket="$HERDR_SOCKET_PATH"
        elif [ -n "''${HERDR_SESSION:-}" ]; then
          socket="$HOME/.config/herdr/sessions/$HERDR_SESSION/herdr.sock"
        else
          socket="$HOME/.config/herdr/herdr.sock"
        fi
        i=0
        while IFS= read -r tab; do
          jq -cn --arg tab "$tab" --argjson i "$i" \
            '{id: "sort", method: "tab.move", params: {tab_id: $tab, insert_index: $i}}' |
            socat -t1 - "UNIX-CONNECT:$socket" >/dev/null
          i=$((i + 1))
        done < <(${herdr} tab list --workspace "$workspace" |
          jq -r '.result.tabs | to_entries
            | sort_by([((.value.label | capture("^(?<n>[0-9]+)(:|$)") | .n | tonumber) // 1e9), .key])
            | .[].value.tab_id')
      '';
    };

    zsh = if pkgs.stdenv.hostPlatform.isDarwin then "/bin/zsh" else lib.getExe pkgs.zsh;

    tabGoto = pkgs.writeText "herdr-tab-goto.zsh" ''
      zmodload zsh/net/socket
      number=$1
      workspace=''${HERDR_ACTIVE_WORKSPACE_ID:?}
      if [[ -n ''${HERDR_SOCKET_PATH:-} ]]; then
        socket=$HERDR_SOCKET_PATH
      elif [[ -n ''${HERDR_SESSION:-} ]]; then
        socket=$HOME/.config/herdr/sessions/$HERDR_SESSION/herdr.sock
      else
        socket=$HOME/.config/herdr/herdr.sock
      fi

      request() {
        zsocket $socket || exit 1
        local fd=$REPLY
        print -r -u $fd -- $1
        IFS= read -r -u $fd reply
        exec {fd}>&-
      }

      request '{"id":"goto","method":"tab.list","params":{"workspace_id":"'$workspace'"}}'
      tabs=''${reply//\},\{/$'\n'}
      for tab in "''${(@f)tabs}"; do
        if [[ $tab =~ "\"label\":\"$number(:[^\"]*)?\"" && $tab =~ '"tab_id":"([^"]+)"' ]]; then
          request '{"id":"goto","method":"tab.focus","params":{"tab_id":"'$match[1]'"}}'
          exit
        fi
      done
      request '{"id":"goto","method":"tab.create","params":{"workspace_id":"'$workspace'","label":"'$number'","focus":true}}'
      exec ${lib.getExe sortTabs} $workspace
    '';

    rename = pkgs.writeShellApplication {
      name = "herdr-rename";
      runtimeInputs = [
        pkgs.jq
        pkgs.gum
      ];
      text = ''
        workspace=$(${herdr} workspace list | jq -c '.result.workspaces[] | select(.focused)')
        workspace_id=$(jq -r .workspace_id <<<"$workspace")
        printf 'rename: [w]tab [s]workspace'
        read -r -s -n 1 target
        echo
        case "$target" in
          w)
            id=$(jq -r .active_tab_id <<<"$workspace")
            tab=$(${herdr} tab get "$id" | jq -c .result.tab)
            label=$(jq -r .label <<<"$tab")
            if [[ "$label" =~ ^([0-9]+)(:(.*))?$ ]]; then
              number="''${BASH_REMATCH[1]}"
              current="''${BASH_REMATCH[3]}"
            else
              number=$(jq -r .number <<<"$tab")
              current="$label"
            fi
            name=$(gum input --no-show-help --prompt "tab $number: " --value "$current")
            ${herdr} tab rename "$id" "$number''${name:+:$name}"
            ;;
          s)
            current=$(jq -r .label <<<"$workspace")
            name=$(gum input --no-show-help --prompt "workspace: " --value "$current")
            ${herdr} workspace rename "$workspace_id" "$name"
            ;;
        esac
      '';
    };

    workspaceHistory = pkgs.writeShellApplication {
      name = "herdr-workspace-history";
      runtimeInputs = [ pkgs.jq ];
      text = ''
        state="$HERDR_PLUGIN_STATE_DIR/$(printf '%s' "$HERDR_SOCKET_PATH" | tr -c 'A-Za-z0-9' _)"
        current=""
        previous=""
        if [ -f "$state" ]; then
          { read -r current || true; read -r previous || true; } <"$state"
        fi
        case "$1" in
          record)
            focused=$(jq -r '.. | objects | .workspace_id? // empty' <<<"$HERDR_PLUGIN_EVENT_JSON" | head -n1)
            if [ -n "$focused" ] && [ "$focused" != "$current" ]; then
              printf '%s\n%s\n' "$focused" "$current" >"$state"
            fi
            ;;
          previous)
            if [ -n "$previous" ]; then
              "$HERDR_BIN_PATH" workspace focus "$previous" >/dev/null
            fi
            ;;
        esac
      '';
    };

    workspaceHistoryPlugin = pkgs.writeTextDir "herdr-plugin.toml" ''
      id = "kwkaiser.workspace-history"
      name = "Workspace history"
      version = "0.1.0"
      min_herdr_version = "0.9.0"
      platforms = ["linux", "macos"]

      [[events]]
      on = "workspace.focused"
      command = ["${lib.getExe workspaceHistory}", "record"]

      [[actions]]
      id = "previous"
      title = "Previous workspace"
      contexts = ["workspace"]
      command = ["${lib.getExe workspaceHistory}", "previous"]
    '';

    tabKeys = map (n: {
      key = "prefix+${toString (lib.mod n 10)}";
      type = "shell";
      command = "${zsh} -f ${tabGoto} ${toString n}";
      description = "go to tab ${toString n}";
    }) (lib.range 1 10);
  in
  {
    home.packages = [ sortTabs ];

    home.activation.herdrWorkspaceHistory = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      run ${herdr} plugin link ${workspaceHistoryPlugin} >/dev/null || true
    '';

    programs.herdr = {
      enable = true;
      settings = {
        onboarding = false;
        ui = {
          toast.delivery = "off";
          sound.enabled = false;
          pane_scrollbars = false;
        };
        theme = {
          name = "terminal";
          auto_switch = false;
        };
        keys = {
          prefix = "ctrl+a";
          goto = "prefix+s";
          settings = "prefix+shift+s";
          new_workspace = "prefix+c";
          new_tab = "prefix+t";
          close_pane = "prefix+q";
          close_workspace = [
            "prefix+shift+d"
            "prefix+x"
          ];
          zoom = "prefix+f";
          split_vertical = "prefix+enter";
          detach = "prefix+d";
          switch_tab = [ ];
          previous_tab = [ ];
          new_worktree = [ ];
          close_tab = [ ];
          resize_mode = "prefix+m";
          navigate_workspace_up = [
            "up"
            "k"
          ];
          navigate_workspace_down = [
            "down"
            "j"
          ];
          navigate_pane_up = "shift+k";
          navigate_pane_down = "shift+j";
          command = tabKeys ++ [
            {
              key = "prefix+p";
              type = "plugin_action";
              command = "kwkaiser.workspace-history.previous";
              description = "previous workspace";
            }
            {
              key = "prefix+r";
              type = "popup";
              command = lib.getExe rename;
              description = "rename tab (w) or workspace (s)";
              width = 50;
              height = 4;
            }
            {
              key = "prefix+g";
              type = "popup";
              command = "tmt pick || { echo 'press enter'; read _; }";
              description = "tmt pick";
              width = "80%";
              height = "70%";
            }
            {
              key = "prefix+o";
              type = "popup";
              command = "tmt switch || { echo 'press enter'; read _; }";
              description = "tmt switch";
              width = "80%";
              height = "70%";
            }
            {
              key = "prefix+shift+g";
              type = "popup";
              command = "tmt create || { echo 'press enter'; read _; }";
              description = "tmt create";
              width = "80%";
              height = "70%";
            }
            {
              key = "prefix+shift+x";
              type = "popup";
              command = "tmt close || { echo 'press enter'; read _; }";
              description = "tmt close";
              width = "60%";
              height = "40%";
            }
          ];
        };
      };
    };
  }
)
