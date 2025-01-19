{ pkgs, lib, inputs, archi, ... }: {

  users.users.kwkaiser = {
    isNormalUser = true;
    home = "/Users/kwkaiser";
    description = "Primary user";
    extraGroups = [ "wheel" "staff" ];
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager = {
    extraSpecialArgs = { inherit inputs archi; };
    users = { "kwkaiser" = { imports = [ ./home.nix ]; }; };
  };
}
