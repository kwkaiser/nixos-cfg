{ pkgs, config, lib, inputs, isDarwin, ... }: {
  options = {
    mine.keepass.enable = lib.mkEnableOption "Whether or not to use keepassxc";
  };

  config = lib.mkIf config.mine.keepass.enable (
    {
      home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
    }
    // lib.optionalAttrs isDarwin {
      # keepassxc in nixpkgs pulls in extra-cmake-modules which is Linux-only;
      # use Homebrew cask on Darwin instead
      homebrew.casks = [ "keepassxc" ];
    }
  );
}
