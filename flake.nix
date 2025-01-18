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

    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = { self, nixpkgs, disko, home-manager, hyprland, ... }@inputs: {
    nixosConfigurations.vm = let system = "x86_64-linux";
    in nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs system; };

      modules = [
        disko.nixosModules.disko
        home-manager.nixosModules.default
        ./modules/os
        ./hosts/vm
      ];
    };

    homeManagerModules.default = ./modules/home;
  };
}
