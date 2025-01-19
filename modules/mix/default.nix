{ pkgs, lib, inputs, archi, ... }: {

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager = {
    extraSpecialArgs = { inherit inputs archi; };
    users = { "kwkaiser" = { imports = [ ./home.nix ]; }; };
  };
}
