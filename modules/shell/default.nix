{ pkgs, config, lib, inputs, archi, ... }: {
  options = {
    foo.alacritty.enabled =
      lib.mkEnableOption "whether or not to use zsh shell";
  };

  config = lib.mkIf config.foo.alacritty.enabled {
    # OS config
    environment.systemPackages = with pkgs; [ alacritty ];

    # Home config
    home-manager.users.${config.bingus.username} = {
      imports = [ ./home.nix ];
    };
  };

}
