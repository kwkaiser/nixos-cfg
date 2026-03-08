{ pkgs, config, lib, ... }: {
  options = {
    mine.rust.enable =
      lib.mkEnableOption "Whether or not to install the Rust toolchain via nixpkgs";
  };

  config = lib.mkIf config.mine.rust.enable {
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
