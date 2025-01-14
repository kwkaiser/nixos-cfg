{
  imports = [
    # Host-specific
    ./disks.nix
    ./boot.nix
    ./hardware.nix
    ./net.nix
    # Modules
    ../../modules/os/common.nix
    ../../modules/os/desktop/tiling.nix
    ../../modules/os/audio/pulse.nix
    ../../modules/os/nix.nix
    ../../modules/os/tz.nix
    ../../modules/os/audio.nix
    ../../modules/os/users.nix
  ];

  tiling.enable = false;

  home-manager.users.kwkaiser = {
    imports = [ ../../modules/home/shell.nix ];
    home.stateVersion = "24.11"; # Match nixpkgs version
  };
}
