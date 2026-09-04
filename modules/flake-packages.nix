{ config, inputs, ... }:
let
  crossArchQemuPackage = hostPkgs: let
    qemu = hostPkgs.qemu;
  in
    qemu
    // {
      stdenv = qemu.stdenv // { hostPlatform = qemu.stdenv.hostPlatform // { isLinux = true; }; };
    };

  # Per-system builds/apps so `nix run .#homelab-vm` picks the qemu host pkgs
  # matching whatever machine you're actually running it from (Linux or the
  # Mac), without needing `--impure` for builtins.currentSystem.
  mkVmPackages = system: let
    hostPkgs = inputs.nixpkgs.legacyPackages.${system};
    vmModules = [
      { virtualisation.vmVariant.virtualisation.host.pkgs = hostPkgs; }
      (inputs.nixpkgs.lib.optionalAttrs (inputs.nixpkgs.lib.hasSuffix "-darwin" system) {
        virtualisation.vmVariant.virtualisation.qemu.package = crossArchQemuPackage hostPkgs;
      })
    ];
  in {
    homelab-vm = (config.flake.nixosConfigurations.homelab.extendModules { modules = vmModules; }).config.system.build.vm;
    homelab-vps-vm = (config.flake.nixosConfigurations.homelab-vps.extendModules { modules = vmModules; }).config.system.build.vm;
    desktop-vm = (config.flake.nixosConfigurations.desktop.extendModules { modules = vmModules; }).config.system.build.vm;
  };
in
{
  config.flake.packages = inputs.nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ] mkVmPackages;

  config.flake.apps = inputs.nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ] (system: {
    homelab-vm = {
      type = "app";
      program = inputs.nixpkgs.lib.getExe config.flake.packages.${system}.homelab-vm;
    };
    homelab-vps-vm = {
      type = "app";
      program = inputs.nixpkgs.lib.getExe config.flake.packages.${system}.homelab-vps-vm;
    };
    desktop-vm = {
      type = "app";
      program = inputs.nixpkgs.lib.getExe config.flake.packages.${system}.desktop-vm;
    };
  });

  config.flake.devShells = inputs.nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ] (system: {
    default = import ../devshell.nix { pkgs = inputs.nixpkgs.legacyPackages.${system}; };
  });
}
