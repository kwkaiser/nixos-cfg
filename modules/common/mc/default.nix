{
  lib,
  config,
  isDarwin,
  ...
}: {
  options = {
    mine.mc.enable = lib.mkEnableOption "Minecraft setup";
  };

  config = lib.mkIf config.mine.mc.enable (
    {
      home-manager.users.${config.mine.username} = {imports = [./home.nix];};
    }
    // lib.optionalAttrs isDarwin {
      # prismlauncher in nixpkgs uses extra-cmake-modules which is Linux-only;
      # use Homebrew cask on Darwin instead
      homebrew.casks = [ "prismlauncher" ];
    }
  );
}
