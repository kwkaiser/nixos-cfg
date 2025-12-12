{ pkgs, config, lib, inputs, ... }: {
  options = {
    mine.homelab-dev.enable =
      lib.mkEnableOption "Whether or not this is a homelab dev station";
  };

  config = lib.mkIf config.mine.homelab-dev.enable {
    networking.extraHosts = ''
      127.0.0.1 kwkaiser-test.io
    '';
  };
}

