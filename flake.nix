{
  description = "kwkaiser's nixos flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko, ... }@inputs: {
    nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };

      modules = [
        ./hosts/mainarray-vm/disks.nix
        disko.nixosModules.disko
        ./hardware.nix
        ./modules/os/k3s-head.nix
        ./modules/os/nix.nix
        ./modules/os/boot.nix
        ./modules/os/net.nix
        ./modules/os/tz.nix
        ./modules/os/audio.nix
        ./modules/os/users.nix
      ];
    };
  };
}
