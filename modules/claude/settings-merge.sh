target="$1"
managed="$2"
tracked="$(dirname "$target")/.nix-managed-settings.json"

if [ ! -f "$target" ] || ! jq -e . "$target" >/dev/null 2>&1; then
  echo '{}' >"$target"
fi

if [ ! -f "$tracked" ] || ! jq -e . "$tracked" >/dev/null 2>&1; then
  echo '[]' >"$tracked"
fi

merged="$(
  jq --slurpfile managed "$managed" --slurpfile tracked "$tracked" \
    'delpaths($tracked[0]) * $managed[0]' "$target"
)"

printf '%s\n' "$merged" >"$target"
chmod 644 "$target"

jq '[paths(type != "object")]' "$managed" >"$tracked"
