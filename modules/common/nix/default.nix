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
  environment.systemPackages = with pkgs; [nixfmt-rfc-style];
  home-manager.users.${config.mine.username} = {
    imports = [./home.nix];
  };
}
// (
  if isDarwin
  then {
    nix = {
      enable = true;
      optimise.automatic = true;
      gc = {
        automatic = true;
        options = "--delete-older-than 3d";
      };
      linux-builder = {
        enable = false;
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        ephemeral = true;
        maxJobs = 6;
        config = {
          virtualisation = {
            cores = 6;
            darwin-builder = {
              diskSize = 30 * 1024;
              memorySize = 6 * 1024;
            };
          };
          # We have to emulate aarch64 on x86 qemu, see https://github.com/golang/go/issues/69255
          boot.binfmt.emulatedSystems = ["x86_64-linux"];
        };
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
  else {
    nix = {
      gc = {
        automatic = true;
        options = "--delete-older-than 3d";
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
