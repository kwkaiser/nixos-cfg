{
  config,
  pkgs,
  inputs,
  ...
}:
{
  home.packages = with pkgs; [
    (writeShellScriptBin "pccp" ''
      kitty --directory ~/Documents/pallet/copallet ccp &
      kitty --directory ~/Documents/pallet/copallet-wt-1 ccp &
      kitty --directory ~/Documents/pallet/copallet-wt-2 ccp &
    '')

    (writeShellScriptBin "pcursor" ''
      cursor ~/Documents/pallet/copallet &
      cursor ~/Documents/pallet/copallet-wt-1 &
      cursor ~/Documents/pallet/copallet-wt-2 &
    '')
  ];
}
