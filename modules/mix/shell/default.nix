{ pkgs, lib, inputs, archi, ... }: {
  options = {
    foo.alacritty.enabled =
      lib.mkEnableOption "whether or not to use zsh shell";
  };

  config = lib.mkIf config.alacritty.enabled {
    environment.systemPackages = with pkgs; [ alacritty ];
    home-manager = {
      extraSpecialArgs = { inherit inputs archi; };
      users = { "kwkaiser" = { imports = [ ./home.nix ]; }; };
    };
  };

}
