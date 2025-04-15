{ inputs, lib, ... }: {
  imports = [ ./boot.nix ./hardware.nix ./net.nix ./tz.nix ];
}
