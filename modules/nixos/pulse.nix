{ config, pkgs, lib, ... }: {
  options = { audio.pulse.enable = lib.mkEnableOption "enables pulse audio"; };

  config = lib.mkIf config.audio.pulse.enable {
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
