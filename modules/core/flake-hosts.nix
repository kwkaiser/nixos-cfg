{
  inputs,
  lib,
  vmTestModule,
  ...
}:
let
  hyprlandOverlay = final: prev: {
    hyprland = inputs.hyprland.packages.${prev.stdenv.hostPlatform.system}.hyprland;
    hyprland-unwrapped = inputs.hyprland.packages.${prev.stdenv.hostPlatform.system}.hyprland-unwrapped;
  };

  allowUnfree = {
    nixpkgs.config.allowUnfree = true;
  };

  mkNixosModules = hostModule: [
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.default
    allowUnfree
    vmTestModule
    { nixpkgs.overlays = [ hyprlandOverlay ]; }
    hostModule
  ];
in
{
  # Unlike `nixosConfigurations`, flake-parts has no built-in option for
  # `darwinConfigurations`, so without this it falls through to the generic
  # freeform flake-output type, which requires the whole attribute be defined
  # exactly once - multiple host files each adding their own key then
  # collides as "defined multiple times".
  options.flake.darwinConfigurations = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = { };
  };

  config._module.args.mkNixosModules = mkNixosModules;

  config._module.args.mkNixosSystem =
    hostModule:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = mkNixosModules hostModule;
    };

  config._module.args.mkDarwinSystem =
    hostModule:
    inputs.nix-darwin.lib.darwinSystem {
      specialArgs = { inherit inputs; };
      modules = [
        inputs.home-manager.darwinModules.default
        inputs.stylix.darwinModules.stylix
        allowUnfree
        { nixpkgs.overlays = [ inputs.nixpkgs-firefox-darwin.overlay ]; }
        hostModule
      ];
    };
}
