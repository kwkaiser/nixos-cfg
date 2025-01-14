{
  # Host specific
  imports = [ ./disks.nix ./boot.nix ./hardware.nix ./net.nix ];

  # Config
  desktop.tiling.enable = true;
  audio.pulse.enable = true;

  home-manager.users.kwkaiser = {
    imports = [ ../../modules/home ];
    home.stateVersion = "24.11"; # Match nixpkgs version
  };

  bingus.shell.zsh = true;
}
