{
  imports = [
    # Host-specific
    ./disks2.nix
    ./hardware.nix
    ./net.nix
    # Modules
    ../../modules/os/k3s-head.nix
    ../../modules/os/nix.nix
    ../../modules/os/boot.nix
    ../../modules/os/tz.nix
    ../../modules/os/audio.nix
    ../../modules/os/users.nix
  ];
}
