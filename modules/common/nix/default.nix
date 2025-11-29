{
  config,
  pkgs,
  isDarwin,
  lib,
  ...
}:
{
  # Global nixpkgs configuration for all systems
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = _: true;
  environment.systemPackages = with pkgs; [ nixfmt-rfc-style ];
  home-manager.users.${config.mine.username} = {
    imports = [ ./home.nix ];
  };

}
// (
  if isDarwin then
    {
      nix = {
        enable = true;
        linux-builder = {
          enable = true;
          systems = [
            "x86_64-linux"
            "aarch64-linux"
          ];
          config.boot.binfmt.emulatedSystems = [ "x86_64-linux" ];
        };
        distributedBuilds = true;
        settings = {
          trusted-users = [
            "@admin"
            "kwkaiser"
            "root"
            "karl"
          ];
          extra-trusted-users = [
            "@admin"
            "kwkaiser"
            "root"
            "karl"
          ];
          experimental-features = [
            "nix-command"
            "flakes"
          ];
        };
      };
    }
  else
    {
      nix = {
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 3d";
          persistent = true;
        };
        optimise = {
          automatic = true;
          persistent = true;
        };
        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
        };
      };
    }
)
