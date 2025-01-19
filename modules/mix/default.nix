{ pkgs, lib, inputs, archi, ... }: {
  # Boiler plate
  users.users.kwkaiser = {
    home = "/Users/kwkaiser";
    description = "Primary user";
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs archi; };
    users = { "kwkaiser" = { imports = [ ./home.nix ]; }; };
  };

  imports = [ ./shell ];
}
