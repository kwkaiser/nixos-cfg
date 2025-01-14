{ inputs, ... }: {
  # Host specific
  imports = [ ./disks.nix ./boot.nix ./hardware.nix ./net.nix ];

  # Config
  audio.pulse.enable = true;

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "kwkaiser" = {
        imports = [ ./home.nix inputs.self.outputs.homeManagerModules.default ];
      };
    };
  };
}
