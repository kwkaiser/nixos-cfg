{
  description = "kwkaiser's nixos flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Pinned nixpkgs for claude-code (2.1.88 was yanked from npm)
    #nixpkgs-claude-code.url = "github:nixos/nixpkgs/55f3084e5d0eb14522f5be012562f80681f50886";

    # Pinned nixpkgs for devbox — must match the copallet repo's CI pin
    # (devbox-version: 0.17.3) so devbox.lock's nodejs plugin_version stops churning.
    nixpkgs-devbox.url = "github:nixos/nixpkgs/3e41b24abd260e8f71dbe2f5737d24122f972158";

    # Pinned nixpkgs for Darwin packages that crash the linker on current
    # nixos-unstable: its ld64/libclang_rt combo crashes (Trace/BPT trap: 5)
    # linking large natively-built binaries (kitty, livekit-libwebrtc/codex).
    nixpkgs-darwin-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    # Firefox has no cached aarch64-darwin build in nixpkgs right now (Hydra's
    # darwin firefox job has been failing since 2026-06-22), so use official
    # .dmg builds repackaged as a nix derivation instead of building from source.
    nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";

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

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    disko,
    home-manager,
    nix-darwin,
    stylix,
    nvf,
    ...
  } @ inputs: let
    # Shared module for unfree packages
    allowUnfree = {
      nixpkgs.config.allowUnfree = true;
    };

    # Helper to create NixOS configurations
    mkNixosSystem = hostModule:
      nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs nixpkgs;
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
    mkDarwinSystem = hostModule:
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
          { nixpkgs.overlays = [ inputs.nixpkgs-firefox-darwin.overlay ]; }
          hostModule
        ];
      };
  in {
    nixosConfigurations = {
      homelab = mkNixosSystem ./hosts/homelab;
      desktop = mkNixosSystem ./hosts/desktop;
    };

    darwinConfigurations."work-macbook" = mkDarwinSystem ./hosts/work-macbook.nix;
  };
}
