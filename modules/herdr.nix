{ lib, ... }:
let
  inherit (import ../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "herdr" (
  { config, pkgs, ... }:
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

    tabGoto = pkgs.writeShellApplication {
      name = "herdr-tab-goto";
      text = ''
        number="$1"
        workspace="''${HERDR_ACTIVE_WORKSPACE_ID:?}"
        tabs=$(${herdr} tab list --workspace "$workspace")
        re="\"label\":\"$number(:[^\"]*)?\",[^}]*\"tab_id\":\"([^\"]+)\""
        if [[ "$tabs" =~ $re ]]; then
          exec ${herdr} tab focus "''${BASH_REMATCH[2]}" >/dev/null
        fi
        ${herdr} tab create --workspace "$workspace" --label "$number" --focus
        ${lib.getExe sortTabs} "$workspace"
      '';
    };

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

    tabKeys = map (n: {
      key = "prefix+${toString (lib.mod n 10)}";
      type = "shell";
      command = "${lib.getExe tabGoto} ${toString n}";
      description = "go to tab ${toString n}";
    }) (lib.range 1 10);
  in
  {
    home.packages = [ sortTabs ];

    programs.herdr = {
      enable = true;
      settings = {
        onboarding = false;
        ui = {
          toast.delivery = "off";
          sound.enabled = false;
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
