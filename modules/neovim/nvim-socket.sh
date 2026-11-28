dir="${1:-$PWD}"
session="${2:-}"

if root="$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null)"; then
  :
elif [ -f "$dir/.tmt" ]; then
  root="$(cd "$dir" && pwd -P)"
else
  exit 1
fi

printf '%s\n' "$root"
printf '/tmp/nvim-%s-%s.sock\n' "$(basename "$root")" "$(printf %s "$session:$root" | cksum | cut -d' ' -f1)"
