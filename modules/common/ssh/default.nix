{
  lib,
  config,
  isDarwin,
  ...
}: {
  options = {
    mine.ssh.enable = lib.mkEnableOption "Enables SSH and SSH agent";
  };

  config = lib.mkIf config.mine.ssh.enable {
    services.openssh.enable = true;

    programs.ssh =
      {
      }
      // lib.optionalAttrs (!isDarwin) {
        startAgent = true;
      };

    home-manager.users.${config.mine.username} = {imports = [./home.nix];};
  };
}
