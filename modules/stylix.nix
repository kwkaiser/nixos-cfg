{ mkModuleOption, ... }:
let
  hmModule = { pkgs, ... }: {
    # home-manager keeps its own nixpkgs.config, separate from the outer
    # NixOS/darwin one even with useUserPackages - joypixels' unfree-license
    # check runs against whichever config produced the `pkgs.joypixels`
    # value actually forced here, so it needs the acceptance too.
    nixpkgs.config.joypixels.acceptLicense = true;
    stylix.enable = true;
    stylix.image = ../assets/backgrounds/bay-wharf.jpg;
    # Other themes available under https://github.com/tinted-theming/base16-schemes
    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
    stylix.targets.firefox.profileNames = [ "kwkaiser" ];
    stylix.targets.firefox.colorTheme.enable = true;
    stylix.targets.nvf.enable = false; # Managed by nvf theme instead
    stylix.fonts.emoji = {
      package = pkgs.joypixels;
      name = "JoyPixels";
    };
    stylix.fonts.monospace = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font Mono";
    };
  };

  systemModule = { config, ... }: {
    # joypixels (used above as the stylix emoji font) is unfree.
    nixpkgs.config.joypixels.acceptLicense = true;
    home-manager.users.${config.mine.username}.imports = [ hmModule ];
  };
in
{
  options.nixos.modules.stylix = mkModuleOption { };
  options.darwin.modules.stylix = mkModuleOption { };
  options.homeManager.modules.stylix = mkModuleOption { };

  config.homeManager.modules.stylix = hmModule;
  config.nixos.modules.stylix = systemModule;
  config.darwin.modules.stylix = systemModule;
}
