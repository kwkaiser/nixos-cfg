{
  pkgs,
  ...
}:
let
  devboxCli = pkgs.writeShellApplication {
    name = "devbox";
    runtimeInputs = [ pkgs.flyctl pkgs.jq ];
    text = ''
      app="''${DEVBOX_APP:-kwkaiser-devbox}"
      org="''${DEVBOX_ORG:-personal}"
      repo="''${DEVBOX_REPO:-$HOME/Documents/nixos-cfg}"

      usage() {
        echo "usage: devbox <deploy|up|down|ssh|status|destroy>" >&2
        exit 1
      }

      machine_id() {
        fly machine list -a "$app" --json | jq -r '.[0].id // empty'
      }

      cmd="''${1:-}"
      case "$cmd" in
        deploy)
          fly apps create "$app" --org "$org" 2>/dev/null || true

          out=$(nix build "$repo#devbox-image" --no-link --print-out-paths)
          docker load -i "$out"
          fly auth docker
          docker tag devbox:latest "registry.fly.io/$app:latest"
          docker push "registry.fly.io/$app:latest"

          id=$(machine_id)
          if [ -z "$id" ]; then
            fly machine run "registry.fly.io/$app:latest" -a "$app" --name devbox
          else
            fly machine update "$id" -a "$app" --image "registry.fly.io/$app:latest" --yes
          fi
          ;;
        up)
          fly machine start "$(machine_id)" -a "$app"
          ;;
        down)
          fly machine stop "$(machine_id)" -a "$app"
          ;;
        ssh)
          fly ssh console -a "$app"
          ;;
        status)
          fly machine list -a "$app"
          ;;
        destroy)
          fly machine destroy "$(machine_id)" -a "$app" --force
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
