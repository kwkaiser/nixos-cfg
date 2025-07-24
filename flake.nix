{
  description = "kwkaiser's nixos flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    hyprland.url = "github:hyprwm/Hyprland";
    stylix.url = "github:danth/stylix/release-25.05";
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
          ./hosts/vm/thin.nix
          ./modules
          ({ pkgs, ... }: { nixpkgs.config.allowUnfree = true; })
        ];
      };

      nixosConfigurations.vm-full = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          isDarwin = false;
        };

        modules = [
          disko.nixosModules.disko
          stylix.nixosModules.stylix
          home-manager.nixosModules.default
          ./hosts/vm/full.nix
          ./modules
          ({ pkgs, ... }: { nixpkgs.config.allowUnfree = true; })
        ];
      };

      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          isDarwin = false;
        };

        modules = [
          disko.nixosModules.disko
          stylix.nixosModules.stylix
          home-manager.nixosModules.default
          ./hosts/desktop
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
