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
        enable = false;
        distributedBuilds = true;
        # external-builders = [{"systems":["aarch64-linux","x86_64-linux"],"program":"/usr/local/bin/determinate-nixd","args":["builder"]}];
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
            "external-builders"
          ];
          extra-experimental-features = "external-builders";
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
