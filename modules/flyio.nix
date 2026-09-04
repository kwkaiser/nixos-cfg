{ lib, ... }:
let
  inherit (import ../dendritic-lib.nix { inherit lib; }) mkHmFeature;
in
mkHmFeature "flyio" (
  { pkgs, ... }:
  let
    devboxCli = pkgs.writeShellApplication {
      name = "devbox-fly";
      runtimeInputs = [
        pkgs.flyctl
        pkgs.jq
      ];
      text = ''
        app="''${DEVBOX_APP:-kwkaiser-devbox}"
        org="''${DEVBOX_ORG:-personal}"

        usage() {
          echo "usage: devbox-fly <deploy|up|down|ssh|status|destroy>" >&2
          exit 1
        }

        machine_id() {
          fly machine list -a "$app" --json | jq -r '.[0].id // empty'
        }

        require_machine_id() {
          local id
          id=$(machine_id)
          if [ -z "$id" ]; then
            echo "no machine found for $app - run 'devbox-fly deploy' first" >&2
            exit 1
          fi
          echo "$id"
        }

        cmd="''${1:-}"
        case "$cmd" in
          deploy)
            fly apps create "$app" --org "$org" 2>/dev/null || true

            id=$(machine_id)
            if [ -z "$id" ]; then
              fly machine run "registry.fly.io/$app:latest" -a "$app" --name devbox
            else
              fly machine update "$id" -a "$app" --image "registry.fly.io/$app:latest" --yes
            fi
            ;;
          up)
            id="$(require_machine_id)"
            fly machine start "$id" -a "$app"
            ;;
          down)
            id="$(require_machine_id)"
            fly machine stop "$id" -a "$app"
            ;;
          ssh)
            fly ssh console -a "$app"
            ;;
          status)
            fly machine list -a "$app"
            ;;
          destroy)
            id="$(require_machine_id)"
            fly machine destroy "$id" -a "$app" --force
            ;;
          *)
            usage
            ;;
        esac
      '';
    };
  in
  {
    home.packages = with pkgs; [
      flyctl
      devboxCli
    ];
  }
)
