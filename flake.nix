{
  description = "kwkaiser's nixos flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, disko, home-manager, ... }@inputs: {
    nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };

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
