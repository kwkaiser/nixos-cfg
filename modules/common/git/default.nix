{ pkgs, config, lib, inputs, ... }: {
  options = {
    mine.git.signsCommits =
      lib.mkEnableOption "Whether or not to sign commits with usual key";
  };

  config = {
    home-manager.users.${config.mine.username} = { imports = [ ./home.nix ]; };
  };
}
