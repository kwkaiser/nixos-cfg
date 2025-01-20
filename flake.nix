{
  description = "kwkaiser's nixos flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs =
    { self, nixpkgs, disko, home-manager, hyprland, nix-darwin, ... }@inputs: {
      nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };

        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.default
          ./hosts/vm
          ./modules/common
          ./modules/nixos
        ];
      };

      darwinConfigurations."finch-macbook" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          home-manager.darwinModules.default
          ./hosts/finch-macbook.nix
          ./modules/common
          ./modules/darwin
        ];
      };
    };
}
