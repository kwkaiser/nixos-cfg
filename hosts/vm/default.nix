{
  # Host specific
  imports = [ ./disks.nix ./boot.nix ./hardware.nix ./net.nix ];

  # Config
  desktop.tiling.enable = true;
  audio.pulse.enable = true;

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      modules = [ ./home.nix inputs.self.outputs.homeManagerModules.default ];
    };
    home.stateVersion = "24.11";
  };
}
