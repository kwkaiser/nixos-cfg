{ pkgs, config, lib, inputs, isDarwin, ... }: {
  imports = (if isDarwin then [
    ./darwin
    ./common
    ./nix.nix
    ./user.nix
  ] else [
    ./nixos
    ./common
    ./nix.nix
    ./user.nix
  ]);

  # HM only modules
  home-manager.extraSpecialArgs = {
    inherit inputs;
    bconfig = config;
    isDarwin = isDarwin;
  };
  home-manager.users.${config.mine.username} = { imports = [ ./hm.nix ]; };
  home-manager.backupFileExtension = "backup";
}
