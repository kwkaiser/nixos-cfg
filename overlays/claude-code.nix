# Overlay to get the latest claude-code version
# Update the version and hashes when a new version is released
final: prev: {
  claude-code = prev.claude-code.overrideAttrs (oldAttrs: rec {
    version = "2.1.78";

    src = prev.fetchzip {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
      hash = "sha256-iyR20O4m1KFqrr2/zqRFVLCIMpvUiGghf/Uqy0T5czU=";
    };

    # NOTE: If this hash is incorrect, nix will tell you the correct one on build
    # Run: nix build .#darwinConfigurations.work-macbook.system --dry-run
    # If it needs to build claude-code, it will show the correct hash on failure
    npmDepsHash = "sha256-sk1RdPMgZD+Ejd6S85gGLUCmsNwH70Sq5rruEs/0hioM=";
  });
}
