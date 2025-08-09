{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "bingus" ''
      echo 'bingus' >> ~/Desktop/bingus.txt
    '')
  ];
}
