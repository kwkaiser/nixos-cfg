{
  config,
  pkgs,
  inputs,
  ...
}:
{
  home.packages = with pkgs; [
    (writeShellScriptBin "pallet-setup" ''
      areospace workspace 3
      kitty --directory ~/Documents/pallet/copallet ccp
    '')
  ];
}
