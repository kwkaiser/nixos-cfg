# Overlay to fix stale claude-code src hash in nixpkgs
# Remove this overlay once nixpkgs updates the hash
final: prev: {
  claude-code = prev.claude-code.overrideAttrs (oldAttrs: {
    version = "2.1.78";
    src = prev.fetchzip {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-2.1.77.tgz";
      hash = "sha256-iyR20O4m1KFqrr2/zqRFVLCIMpvUiGghf/Uqy0T5czU=";
    };
  });
}
