{ inputs, mkModuleOption, ... }:
let
  hmRoot = { ... }: {
    home.stateVersion = "24.11";
    nixpkgs.config.allowUnfree = true;
  };

  mkGlue =
    extraSharedModules:
    { config, ... }: {
      home-manager = {
        useUserPackages = true;
        backupFileExtension = "backup-before-nix";
        # A handful of home.nix bodies reference `inputs` directly (pinned
        # nixpkgs for a specific package, mostly) - home-manager doesn't
        # provide it as a standard module arg, so thread it through here.
        extraSpecialArgs = { inherit inputs; };
        sharedModules = [
          inputs.stylix.homeModules.stylix
          inputs.nvf.homeManagerModules.default
        ] ++ extraSharedModules;
        users.${config.mine.username}.imports = [ hmRoot ];
      };
    };
in
{
  options.nixos.modules.base = mkModuleOption { };
  options.darwin.modules.base = mkModuleOption { };

  # plasma-manager is KDE-only; only nixos hosts (via ./kde.nix) ever use it.
  # Keeping it out of the darwin shared modules avoids a plasma-manager bug
  # where an assertion's `message` is forced unconditionally, even when the
  # assertion holds, which otherwise crashes darwin evaluation.
  config.nixos.modules.base = mkGlue [ inputs.plasma-manager.homeModules.plasma-manager ];
  config.darwin.modules.base = mkGlue [ ];
}
