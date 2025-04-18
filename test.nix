# test.nix
with import <nixpkgs> { system = "x86_64-linux"; };
runCommand "test-linux" { } ''
  echo "built on linux" > $out
''

