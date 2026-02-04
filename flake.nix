{
  description = "kwkaiser's nixos flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    hyprland.url = "github:hyprwm/Hyprland";
    stylix.url = "github:danth/stylix";
  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
      home-manager,
      nix-darwin,
      stylix,
      ...
    }@inputs:
    let
      # Shared module for unfree packages
      allowUnfree = {
        nixpkgs.config.allowUnfree = true;
      };

      # Helper to create NixOS configurations
      mkNixosSystem =
        hostModule:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            isDarwin = false;
          };
          modules = [
            disko.nixosModules.disko
            home-manager.nixosModules.default
            ./modules
            allowUnfree
            hostModule
          ];
        };

      # Helper to create Darwin configurations
      mkDarwinSystem =
        hostModule:
        nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit inputs;
            isDarwin = true;
          };
          modules = [
            home-manager.darwinModules.default
            stylix.darwinModules.stylix
            ./modules
            allowUnfree
            hostModule
          ];
        };
    in
    {
      nixosConfigurations = {
        homelab = mkNixosSystem ./hosts/homelab;
        desktop = mkNixosSystem ./hosts/desktop;
      };

      darwinConfigurations."work-macbook" = mkDarwinSystem ./hosts/work-macbook.nix;
    };
}
