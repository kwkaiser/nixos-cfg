{ pkgs, config, lib, inputs, ... }: {

  imports = [
    ./hyprland
    ./waybar
    ./rofi
    ./swaync
    ./kde
    ./sunshine
    ./remote-unlock
    ./k3s
  ];
}

