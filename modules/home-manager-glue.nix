{ inputs, mkModuleOption, ... }:
let
  hmRoot = { ... }: {
    home.stateVersion = "24.11";
    nixpkgs.config.allowUnfree = true;
  };

  glue = { config, ... }: {
    home-manager = {
      useUserPackages = true;
      backupFileExtension = "backup-before-nix";
      # A handful of home.nix bodies reference `inputs` directly (pinned
      # nixpkgs for a specific package, mostly) - home-manager doesn't
      # provide it as a standard module arg, so thread it through here.
      extraSpecialArgs = { inherit inputs; };
      sharedModules = [
        inputs.plasma-manager.homeModules.plasma-manager
        inputs.stylix.homeModules.stylix
        inputs.nvf.homeManagerModules.default
      ];
      users.${config.mine.username}.imports = [ hmRoot ];
    };
  };
in
{
  options.nixos.modules.base = mkModuleOption { };
  options.darwin.modules.base = mkModuleOption { };

  config.nixos.modules.base = glue;
  config.darwin.modules.base = glue;
}
