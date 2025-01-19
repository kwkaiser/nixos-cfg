{ pkgs, lib, inputs, archi, ... }: {

  users.users.kwkaiser = {
    home = "/Users/kwkaiser";
    description = "Primary user";
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager = {
    extraSpecialArgs = { inherit inputs archi; };
    users = { "kwkaiser" = { imports = [ ./home.nix ]; }; };
  };
}
