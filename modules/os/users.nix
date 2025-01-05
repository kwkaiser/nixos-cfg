{ config, pkgs, ... }: {
  users.users.kwkaiser = {
    isNormalUser = true;
    description = "kwkaiser";
    extraGroups = [ "networkmanager" "wheel" ];
    initialPassword = "bingus";
  };
}
