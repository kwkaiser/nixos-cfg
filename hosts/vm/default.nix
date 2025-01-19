{ inputs, archi, ... }: {
  # Host specific
  imports = [ ./disks.nix ./boot.nix ./hardware.nix ./net.nix ];

  # Config
  audio.pulse.enable = true;
  desktop.tiling.enable = true;

  home-manager = {
    extraSpecialArgs = { inherit inputs archi; };
    users = {
      "kwkaiser" = {
        imports = [ ./home.nix inputs.self.outputs.homeManagerModules.default ];
      };
    };
  };
}
