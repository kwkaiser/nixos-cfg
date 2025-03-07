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

    nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = { self, nixpkgs, disko, home-manager, hyprland, nix-darwin
    , nix-colors, ... }@inputs: {
      nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          isDarwin = false;
        };

        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.default
          ./hosts/vm
          ./modules
          ({ pkgs, ... }: { nixpkgs.config.allowUnfree = true; })
        ];
      };

      darwinConfigurations."finch-macbook" = nix-darwin.lib.darwinSystem {
        specialArgs = {
          inherit inputs;
          isDarwin = true;
        };
        modules = [
          home-manager.darwinModules.default
          ./hosts/finch-macbook.nix
          ./modules
          ({ pkgs, ... }: { nixpkgs.config.allowUnfree = true; })
        ];
      };
    };
}
