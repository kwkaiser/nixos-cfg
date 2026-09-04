{ pkgs }:
pkgs.mkShell {
  # nodejs provides npx, used to run the opnsense MCP server declared in
  # .mcp.json - its OPNSENSE_URL/API_KEY/API_SECRET come from the
  # gitignored .env file (already loaded by .envrc), not from here.
  packages = [
    pkgs.nodejs_22
    pkgs.opentofu
    pkgs.flyctl
    pkgs.skopeo
  ];
}
