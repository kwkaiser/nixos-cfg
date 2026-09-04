{ inputs, ... }:
let
  hyprlandOverlay = final: prev: {
    hyprland = inputs.hyprland.packages.${prev.stdenv.hostPlatform.system}.hyprland;
    hyprland-unwrapped = inputs.hyprland.packages.${prev.stdenv.hostPlatform.system}.hyprland-unwrapped;
  };

  allowUnfree = {
    nixpkgs.config.allowUnfree = true;
  };
in
{
  config._module.args.mkNixosSystem = hostModule:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        inputs.disko.nixosModules.disko
        inputs.home-manager.nixosModules.default
        allowUnfree
        { nixpkgs.overlays = [ hyprlandOverlay ]; }
        hostModule
      ];
    };

  config._module.args.mkDarwinSystem = hostModule:
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
