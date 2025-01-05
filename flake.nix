{
  description = "kwkaiser's nixos flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko, ... }@inputs: {
    nixosConfigurations.mainarray-vm = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };

      modules = [ ./hosts/mainarray-vm disko.nixosModules.disko ];
    };
  };
}
