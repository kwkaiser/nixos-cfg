{
  description = "kwkaiser's nixos flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
    stylix.url = "github:danth/stylix/release-24.11";
  };

  outputs = { self, nixpkgs, disko, home-manager, hyprland, nix-darwin, stylix
    , ... }@inputs: {
      nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          isDarwin = false;
        };

        modules = [
          disko.nixosModules.disko
          stylix.nixosModules.stylix
          home-manager.nixosModules.default
          ./hosts/vm-common
          ./hosts/vm/full.nix
          ./modules
          ({ pkgs, ... }: { nixpkgs.config.allowUnfree = true; })
        ];
      };

      nixosConfigurations.vm-thin = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          isDarwin = false;
        };

        modules = [
          disko.nixosModules.disko
          stylix.nixosModules.stylix
          home-manager.nixosModules.default
          ./hosts/vm-common
          ./hosts/vm/thin.nix
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
          stylix.darwinModules.stylix
          ./hosts/finch-macbook.nix
          ./modules
          ({ pkgs, ... }: { nixpkgs.config.allowUnfree = true; })
        ];
      };
    };
}
