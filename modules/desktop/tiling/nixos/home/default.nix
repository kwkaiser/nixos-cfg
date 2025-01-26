{ pkgs, lib, config, inputs, home, bconfig, ... }: {
  imports = [ ./hyprland.nix ./waybar.nix ];
}
