{ config, pkgs, inputs, ... }: {

  home-manager.users.kwkaiser = {
    extraSpecialArgs = { inherit inputs; };
    users = { modules = [ inputs.self.outputs.homeManagerModules.default ]; };
    # imports = [ ../../modules/home/shell.nix ];
    # home.stateVersion = "24.11"; # Match nixpkgs version
  };
}
