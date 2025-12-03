{ pkgs, lib, config, ... }: {

  options = {
    mine.k3s.enable =
      lib.mkEnableOption "Enables k3s Kubernetes control server";
  };

  config = lib.mkIf config.mine.k3s.enable {
    services.k3s = {
      enable = true;
      role = "server";
    };

    # Add kubectl for convenience
    environment.systemPackages = with pkgs; [ kubectl ];
  };
}
